# AGENTS.md — ha-claude-go-dev

Інструкції для AI-агентів (Claude Code та інших) і людей, які змінюють цей репозиторій.

## Що це

Доповнення Home Assistant OS **Claude Code Go Dev**. Це **похідне** від базового доповнення
[AnhoUA/ha-claude](https://github.com/AnhoUA/ha-claude) і нічого не дублює з нього:

```
ghcr.io/home-assistant/{arch}-base          (Alpine + bashio + s6)
        └── ghcr.io/anhoua/{arch}-addon-claude_code:<версія>          ← AnhoUA/ha-claude
                └── ghcr.io/anhoua/{arch}-addon-claude_code_go_dev:<версія>   ← цей репозиторій
```

Зв'язок з базою — три точки:

| Що | Де тут | Звідки в базі |
|---|---|---|
| Базовий образ | `claude_code_go_dev/build.yaml` → `build_from` з тегом версії | образи, які публікує ha-claude |
| Логіка запуску | `claude_code_go_dev/rootfs/etc/claude/init.d/*.sh` | `run.sh` бази підключає їх через `source` перед стартом Claude |
| CI та випуск версій | `.github/workflows/build.yaml` → `uses: AnhoUA/ha-claude/.github/workflows/build.yaml@main` | reusable workflow бази |

## Головне правило: куди вносити зміну

**Усе, що стосується самого Claude і загальної роботи доповнення, вносьте в базу (ha-claude).
Усе, що стосується розробки, вносьте сюди (go-dev).**

| Зміна | Куди |
|---|---|
| Встановлення чи оновлення Claude Code, Node.js | **база** |
| Веб-термінал (ttyd), tmux, `run.sh`, `claude-start` | **база** |
| Remote Control, `session_name`, `anthropic_api_key` | **база** |
| Постійне сховище (`claude-storage`, `storage_path`, симлінки скілів) | **база** |
| Доступ до HA (`map`, `homeassistant_api`, `ha_api`, ingress) | **база** |
| Загальні утиліти, потрібні будь-якому варіанту (`git`, `jq`, `curl`, `ripgrep`) | **база** |
| Механізм хуків `init.d`, сам workflow збирання | **база** |
| Мова Go, `gopls`, лінтери, `build-base` | **go-dev** |
| GitHub CLI, SSH, git-ідентичність і токени (`git_user_*`, `github_token`) | **go-dev** |
| Інші інструменти розробки (make, task, protobuf, БД-клієнти тощо) | **go-dev** |
| Скрипти `init.d`, що налаштовують інструменти розробки | **go-dev** |

Якщо сумніваєтеся, запитайте себе: «чи потрібно це людині, яка просто спілкується з Claude
про свій Home Assistant?» Якщо так, зміна йде в базу, якщо ні — сюди.

Не копіюйте сюди файли з бази (`run.sh`, `claude-start`, `claude-storage`, `bashrc`), щоб виправити
їх тут. Виправляйте в ha-claude, випускайте нову версію бази й оновлюйте `build.yaml` тут.

## Сценарії оновлення

### 1. Зміна лише в go-dev

1. Змініть `claude_code_go_dev/` (Dockerfile, `rootfs/`, `config.yaml`).
2. Збільште `version` у `claude_code_go_dev/config.yaml` (SemVer: виправлення → patch, нове → minor).
3. Додайте розділ `## <версія>` на початок `claude_code_go_dev/CHANGELOG.md`.
4. Запуште зміни в `main`. CI збере `amd64` і `aarch64`, опублікує образи й створить тег `v<версія>` та GitHub Release.

### 2. Зміна в базі, яку має отримати go-dev

1. У **AnhoUA/ha-claude**: зробіть зміну, збільште версію, оновіть CHANGELOG, запуште й дочекайтеся
   зеленого CI та релізу `v<X.Y.Z>`.
2. Тут, у `claude_code_go_dev/build.yaml`, замініть тег бази для **обох** архітектур на `:<X.Y.Z>`.
3. Якщо база додала, перейменувала чи прибрала опції, синхронізуйте `options` і `schema`
   у `claude_code_go_dev/config.yaml` (див. нижче).
4. Збільште версію go-dev і напишіть у CHANGELOG `Базу оновлено до ha-claude X.Y.Z` з короткими змінами.
5. Запуште зміни в `main`.

### 3. Лише свіжий Claude Code

Claude Code встановлюється в **базовому** образі під час його збирання. Щоб go-dev отримав нову
версію Claude, випустіть patch-версію бази, а потім пройдіть сценарій 2.

## Інваріанти, які не можна порушувати

- **Опції бази мають бути в `config.yaml`.** `run.sh` бази читає `remote_control`, `session_name`,
  `storage_path` і `anthropic_api_key` через bashio. Якщо їх немає в options/schema, доповнення не стартує.
  Тримайте їх першими в тому ж порядку, що й у базі, а власні опції go-dev додавайте після.
- **Тег бази закріплений на конкретній версії**, не `:latest`, щоб збирання було відтворюваним.
- **У Dockerfile немає `CMD`/`ENTRYPOINT`**, вони успадковуються з бази (`/run.sh`).
- **Хуки `init.d`** — це файли `NN-назва.sh` без shebang, бо їх підключають через `source`:
  - доступні `bashio::config`, `bashio::log.*` і `HOME=/data`;
  - змінні, які ви експортуєте, побачить Claude;
  - не використовуйте `exit` і не запускайте довгі блокувальні процеси, бо це зламає старт.
- **Стан, що має переживати перезапуск** (ключі, кеші, конфіги), кладіть у `/data`. Те, що має переживати
  видалення доповнення, кладіть у `storage_path`.
- **`slug` (`claude_code_go_dev`) не змінюйте**, бо це зламає встановлені копії в HA.
- **Кожна версія публікується лише один раз.** Пуш змін у `claude_code_go_dev/` без нової версії зламає CI.

## Локальна перевірка перед пушем

```bash
# зібрати образ go-dev на базі опублікованої бази (amd64)
cd claude_code_go_dev
docker build \
  --build-arg BUILD_FROM=$(awk '$1=="amd64:" {print $2}' build.yaml) \
  --build-arg BUILD_ARCH=amd64 --build-arg BUILD_VERSION=dev \
  -t go-dev-test .

# інструменти на місці
docker run --rm --entrypoint bash go-dev-test -c 'claude --version; go version; gh --version | head -1'

# лінтер workflow
docker run --rm -v "$PWD/..:/repo" -w /repo rhysd/actionlint:latest
```

Щоб протестувати зміну бази ще до її релізу, зберіть базу локально з тегом, який очікує `build.yaml`
(наприклад, `ghcr.io/anhoua/amd64-addon-claude_code:0.5.0`), і після цього зберіть go-dev як вище.

## Публікація

- Образи потрапляють у `ghcr.io/anhoua/{amd64,aarch64}-addon-claude_code_go_dev`. `aarch64` — це
  arm64 (Raspberry Pi 4/5, HA Green/Yellow), його збирає нативний ARM-раннер.
- Пакети GHCR мають бути **публічними**, інакше HA отримає `denied` під час встановлення.
  Нові пакети (наприклад, нова архітектура) перевіряйте так:
  `docker buildx imagetools inspect ghcr.io/anhoua/<arch>-addon-claude_code_go_dev:<версія>`.
- Документацію для користувачів (`README.md`) і цей файл можна змінювати без нової версії:
  CI запускається лише на зміни в `claude_code_go_dev/` та workflow.

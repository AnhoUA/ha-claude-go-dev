# ha-claude-go-dev

Доповнення для Home Assistant OS: **Claude Code** разом з інструментами для розробки на **Go** і роботи з **git/GitHub**.

Воно наслідує [ha-claude](https://github.com/AnhoUA/ha-claude): образ будується `FROM` готового образу ha-claude, тож веб-термінал, Remote Control, постійне сховище скілів і проєктів та доступ до HA працюють так само, як там. Тут описано лише те, що додано зверху. Решту дивіться в [README ha-claude](https://github.com/AnhoUA/ha-claude#readme).

| Що додано | Деталі |
|---|---|
| **Go** | з пакетів Alpine, разом із `build-base` (gcc, make) для cgo |
| **git** | `user.name` та `user.email` з налаштувань |
| **GitHub CLI** | `gh`, авторизація через токен або `gh auth login` |
| **SSH** | `ssh`, `ssh-keygen`; ключі в `~/.ssh` зберігаються між перезапусками |

> Архітектури: `amd64` і `aarch64`.

---

## Встановлення

[![Додати репозиторій у Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FAnhoUA%2Fha-claude-go-dev)

1. У Home Assistant відкрийте **Settings → Add-ons → Add-on Store → ⋮ → Repositories**.
2. Додайте `https://github.com/AnhoUA/ha-claude-go-dev` і натисніть **Close**.
3. Оновіть сторінку, знайдіть **Claude Code Go Dev** і натисніть **Install**. HA завантажить готовий образ з GHCR.
4. На вкладці **Info** увімкніть **Start on boot** і **Show in sidebar**, потім натисніть **Start**.
5. Відкрийте **Claude Go** у бічній панелі й увійдіть у Claude, як описано в [ha-claude](https://github.com/AnhoUA/ha-claude#перший-запуск).

Можна встановити й **Claude Code**, і **Claude Code Go Dev** одночасно. Вони мають однакове `storage_path` (`/share/claude`), тож бачать ті самі скіли й проєкти. Логін Claude і токени в кожного доповнення свої, бо зберігаються в `/data`.

---

## Налаштування

Базові опції, як у ha-claude:

| Опція | За замовчуванням | Опис |
|---|---|---|
| `remote_control` | `true` | Запускати Claude одразу з Remote Control |
| `session_name` | `Home Assistant Go` | Назва сесії в списку Remote Control |
| `storage_path` | `/share/claude` | Постійне сховище для скілів і проєктів |
| `anthropic_api_key` | — | Необов'язкова. Без неї Claude працює з вашою підпискою claude.ai. Якщо ключ задано, Remote Control вимикається |

Додаткові опції (усі необов'язкові, приховані під *Show unused optional configuration options*):

| Опція | Опис |
|---|---|
| `git_user_name` | `git config user.name` |
| `git_user_email` | `git config user.email` |
| `github_token` | Personal access token GitHub для `git push/pull` по HTTPS і для `gh` |

---

## Git і GitHub

Є три способи авторизуватися в GitHub. Усі дані зберігаються в `/data`.

**Токен у налаштуваннях.** Створіть [fine-grained token](https://github.com/settings/personal-access-tokens) з доступом до потрібних репозиторіїв і вставте його в `github_token`. Після перезапуску працюють і `git`, і `gh`.

**Вхід через `gh`.** У терміналі доповнення виконайте:
```bash
gh auth login
gh auth setup-git
```

**SSH-ключ.** Створіть ключ:
```bash
ssh-keygen -t ed25519 -C "ha-claude-go-dev"
cat ~/.ssh/id_ed25519.pub
```
Потім додайте публічний ключ на GitHub у **Settings → SSH and GPG keys**.

Щоб тримати конфігурацію HA під git:
```bash
cd /homeassistant
git init
git remote add origin git@github.com:<логін>/ha-config.git
```
Обов'язково додайте `secrets.yaml`, `.storage/` і `*.db` у `.gitignore`.

---

## Go

`GOPATH=/data/go` і кеш збірки зберігаються між перезапусками. `go install` кладе бінарники в `/data/go/bin`, який уже додано в `PATH`. Проєкти зручно тримати в `~/projects`: це постійне сховище, яке не залежить від контейнера.

```bash
go version
go install golang.org/x/tools/gopls@latest
cd ~/projects && mkdir myapp && cd myapp && go mod init myapp
```

---

## Як це влаштовано

```
ha-claude-go-dev/
├── AGENTS.md                         # як оновлювати: що йде в базу, що в go-dev
├── CLAUDE.md                         # підключає AGENTS.md для Claude Code
├── repository.yaml
├── .github/workflows/build.yaml      # викликає reusable workflow з AnhoUA/ha-claude
└── claude_code_go_dev/
    ├── config.yaml                   # базові опції ha-claude та git-опції
    ├── build.yaml                    # база: ghcr.io/anhoua/{arch}-addon-claude_code:<версія>
    ├── Dockerfile                    # FROM бази + apk add go build-base github-cli openssh-client
    ├── CHANGELOG.md
    └── rootfs/etc/claude/init.d/
        └── 50-git.sh                 # хук запуску: git config, GH_TOKEN, ~/.ssh
```

`run.sh` з базового образу перед стартом Claude підключає всі `/etc/claude/init.d/*.sh`. Так go-dev додає свою логіку, не копіюючи стартовий скрипт.

Правила, куди вносити зміни (у базу чи сюди) і як оновлювати доповнення, описано в [`AGENTS.md`](AGENTS.md). Claude Code підхоплює їх автоматично через `CLAUDE.md`.

---

## Випуск версій

Збирання і випуск версій наслідуються з ha-claude через `uses: AnhoUA/ha-claude/.github/workflows/build.yaml@main`:

1. Збільште `version` у [`claude_code_go_dev/config.yaml`](claude_code_go_dev/config.yaml) і додайте розділ у [`CHANGELOG.md`](claude_code_go_dev/CHANGELOG.md).
2. Запуште зміни в `main`. Workflow збере `ghcr.io/anhoua/{amd64,aarch64}-addon-claude_code_go_dev:<версія>`, створить тег `v<версія>` і GitHub Release.

**Як оновити базу.** Коли виходить нова версія ha-claude, змініть тег в [`build.yaml`](claude_code_go_dev/build.yaml) (наприклад, `:0.4.0` → `:0.5.0`), збільште версію go-dev і запуште зміни.

Пакети `amd64-addon-claude_code_go_dev` і `aarch64-addon-claude_code_go_dev` у GHCR після першого збирання треба зробити публічними: **github.com/orgs/AnhoUA/packages → Package settings → Change visibility → Public**.

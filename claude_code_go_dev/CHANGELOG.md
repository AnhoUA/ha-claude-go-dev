# Changelog

## 0.1.3

- Базу оновлено до ha-claude 0.4.3:
  - текст у терміналі виділяється звичайним протягуванням мишею;
  - посилання для входу в Claude виводиться одним рядком на вкладку Log доповнення.

## 0.1.2

- Базу оновлено до ha-claude 0.4.2:
  - посилання для входу в Claude приходить сповіщенням у Home Assistant;
  - виділення мишею в терміналі працює з Option на Mac і з Shift на Windows і Linux;
  - копіювання з Claude передається в буфер обміну браузера через OSC 52.

## 0.1.1

- Базу оновлено до ha-claude 0.4.1.
- Необов'язкові опції `anthropic_api_key`, `git_user_name`, `git_user_email` і `github_token` більше не показуються на вкладці Configuration за замовчуванням. Задати їх можна через **Show unused optional configuration options**. Без API-ключа Claude працює з підпискою claude.ai.

## 0.1.0

- Перший реліз на базі [ha-claude](https://github.com/AnhoUA/ha-claude) 0.4.0.
- Go з `build-base` для cgo; `GOPATH` і кеш збірки в `/data`.
- git, GitHub CLI (`gh`) і SSH-клієнт; опції `git_user_name`, `git_user_email` і `github_token`.

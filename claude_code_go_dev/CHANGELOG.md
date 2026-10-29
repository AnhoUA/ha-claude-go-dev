# Changelog

## 0.1.1

- Базу оновлено до ha-claude 0.4.1.
- Необов'язкові опції `anthropic_api_key`, `git_user_name`, `git_user_email` і `github_token` більше не показуються на вкладці Configuration за замовчуванням. Задати їх можна через **Show unused optional configuration options**. Без API-ключа Claude працює з підпискою claude.ai.

## 0.1.0

- Перший реліз на базі [ha-claude](https://github.com/AnhoUA/ha-claude) 0.4.0.
- Go з `build-base` для cgo; `GOPATH` і кеш збірки в `/data`.
- git, GitHub CLI (`gh`) і SSH-клієнт; опції `git_user_name`, `git_user_email` і `github_token`.

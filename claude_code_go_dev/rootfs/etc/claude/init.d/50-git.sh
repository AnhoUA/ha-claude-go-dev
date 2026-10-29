# Підключається з run.sh базового образу ha-claude (через source), тож bashio доступний.
# ~/.ssh, ~/.gitconfig і логін gh лежать у /data і зберігаються між перезапусками.

mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"

if bashio::config.has_value 'git_user_name'; then
    git config --global user.name "$(bashio::config 'git_user_name')"
fi
if bashio::config.has_value 'git_user_email'; then
    git config --global user.email "$(bashio::config 'git_user_email')"
fi

if bashio::config.has_value 'github_token'; then
    export GH_TOKEN="$(bashio::config 'github_token')"
    gh auth setup-git
    bashio::log.info "GitHub: використовується github_token з налаштувань"
fi

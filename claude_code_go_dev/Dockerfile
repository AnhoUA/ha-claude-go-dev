# Наслідує образ ha-claude: Claude Code, веб-термінал, Remote Control і сховище вже там.
# Тут додаються лише інструменти розробки на Go та робота з git/GitHub.
ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG BUILD_ARCH
ARG BUILD_VERSION
LABEL io.hass.type="addon" \
      io.hass.arch="${BUILD_ARCH}" \
      io.hass.version="${BUILD_VERSION}" \
      io.hass.name="Claude Code Go Dev"

RUN apk add --no-cache \
        build-base \
        github-cli \
        go \
        openssh-client

# Go-модулі та кеш збірки лежать у /data, щоб не завантажувати їх після кожного перезапуску
ENV GOPATH=/data/go \
    GOCACHE=/data/.cache/go-build \
    PATH=/data/go/bin:${PATH}

# run.sh базового образу виконує /etc/claude/init.d/*.sh перед стартом Claude
COPY rootfs/ /

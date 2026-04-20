FROM jenkins/inbound-agent:alpine-jdk21

USER root

# 기본 패키지 설치
RUN apk update && apk add -u libcurl curl

# Docker CLI 설치 (24.0.6)
ARG DOCKER_VERSION=24.0.6
RUN curl -fsSL https://download.docker.com/linux/static/stable/$(uname -m)/docker-${DOCKER_VERSION}.tgz \
    | tar --strip-components=1 -xz -C /usr/local/bin docker/docker

# Docker Compose 설치 (1.21.0)
ARG DOCKER_COMPOSE_VERSION=1.21.0
RUN curl -fsSL https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m) \
    > /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# kubectl 설치
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod 755 kubectl \
    && mv kubectl /bin

USER jenkins

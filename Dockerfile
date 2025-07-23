FROM fedora:latest

RUN dnf install -y git golang make dnf-utils shadow-utils glibc-devel gcc
RUN dnf config-manager addrepo --from-repofile=https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
RUN dnf install -y vault-1.19.4-1

ENV GOPROXY=https://proxy.golang.org

WORKDIR /src

COPY . .

RUN go mod download && \
    go build -o transiteth builtin/logical/transit/cmd/transit/main.go && \
    chmod +x transiteth

RUN mkdir -p /opt/vault_plugins
RUN mkdir -p /opt/vault_data
RUN cp /src/transiteth /opt/vault_plugins/transiteth
COPY start.sh /start.sh
RUN chmod +x /start.sh
RUN chmod +x /usr/bin/vault
RUN chmod +x /usr/sbin/vault

CMD ["/start.sh"]
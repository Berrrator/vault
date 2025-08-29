ARG GO_VERSION=1.24.5

FROM --platform=$BUILDPLATFORM golang:${GO_VERSION} AS builder

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o transiteth ./builtin/logical/transit/cmd/transit/main.go

FROM hashicorp/vault:latest

USER root
RUN apk add --no-cache jq

COPY --from=builder /src/transiteth /opt/vault_plugins/transiteth

RUN chmod +x /opt/vault_plugins/transiteth

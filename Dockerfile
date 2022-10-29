FROM golang:alpine AS caddy
RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest && \
    xcaddy build latest && \
    git clone --progress https://github.com/XTLS/Xray-core.git . && \
    CGO_ENABLED=0 go build -o /tmp/xray -trimpath -ldflags "-s -w -buildid=" ./main


FROM alpine:latest

COPY conf /conf/
COPY entrypoint.sh /usr/bin
COPY --from=caddy /go/caddy /usr/bin
COPY --from=caddy /tmp/xray /usr/bin


RUN set -ex \
    && apk add --no-cache ca-certificates tor \
    && chmod +x /usr/bin/caddy \
    && chmod +x /usr/bin/entrypoint.sh \
    && chmod +x /usr/bin/xray 
	
CMD /usr/bin/entrypoint.sh	

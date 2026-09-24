FROM alpine:latest

RUN apk add --no-cache bash curl jq tzdata

COPY ionos_update.sh /usr/local/bin/ionos_update.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/ionos_update.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

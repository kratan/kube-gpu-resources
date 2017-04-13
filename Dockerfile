FROM alpine:3.5
RUN apk --no-cache add --update curl jq
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

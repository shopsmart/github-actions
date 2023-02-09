FROM alpine:3.16

ARG VERSION=latest

WORKDIR /app

RUN echo '{"version": "'"$VERSION"'"}' > info.json

CMD [ "cat", "/app/info.json" ]

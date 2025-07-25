FROM alpine:latest AS release
RUN apk add --no-cache git

ARG GIT_REVISION
ARG GIT_REPO_URL

WORKDIR /root

RUN set -ex \
  && git clone $GIT_REPO_URL release -b $GIT_REVISION --depth 1

FROM elixir:1.18-otp-27

ENV MIX_ENV=prod
ENV DATABASE_URL=ecto://postgres:postgres@admin-db/gup_admin_dev
ENV TZ=Europe/Stockholm
ENV SECRET_KEY_BASE=tmp
RUN apt-get update && \
    apt-get install -y postgresql-client && \
    apt-get install -y inotify-tools && \
    apt-get clean && rm -f /var/lib/apt/lists/*_*

RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /app

COPY --from=release /root/release/backend ./

RUN mix deps.get && mix deps.compile && mix compile && mix phx.digest

COPY wait-for-it.sh /usr/local/bin/wait-for-it.sh

CMD ["/usr/local/bin/wait-for-it.sh", "db:5432", "-t", "0", "--", "mix", "phx.server"]

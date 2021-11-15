ARG ELIXIR_VERSION
ARG ERLANG_VERSION
FROM hexpm/elixir:$ELIXIR_VERSION-erlang-$ERLANG_VERSION-ubuntu-focal-20210325

# Common dependencies
RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential \
  inotify-tools \
  curl \
  && apt-get clean \
  && rm -rf /var/cache/apt/archives/* \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

RUN apt-get update -qq && \
  curl -sL https://deb.nodesource.com/setup_14.x | bash -; \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install -y nodejs && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  truncate -s 0 /var/log/*log

#RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y imagemagick --no-install-recommends

RUN mix do local.hex --force, local.rebar --force

RUN mkdir -p /app
WORKDIR /app

EXPOSE 4000

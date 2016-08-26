FROM scardon/ruby-node-alpine:2.2.5

MAINTAINER Daniel Leong

ENV PACKAGES "binutils-gold \
  g++ \
  gcc \
  libgcc \
  libstdc++ \
  libxml2-dev \
  libxslt-dev \
  linux-headers \
  make \
  python \
  libffi-dev \
  postgresql-client \
  postgresql-dev \
  imagemagick-dev \
  git \
  tzdata \
  ${ADDT_PACKAGES}"

RUN apk add --no-cache ${PACKAGES}

WORKDIR /app
COPY [".", "/app"]
ENV BUNDLE_GEMFILE /app/Gemfile

RUN bundle install --jobs=15
RUN bundle exec rake assets:clean && bundle exec rake assets:precompile --jobs=15
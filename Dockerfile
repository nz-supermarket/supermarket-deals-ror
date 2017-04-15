FROM scardon/ruby-node-alpine:2.3.3

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

# Install Nginx.
RUN apk add --no-cache nginx
RUN mkdir -p /run/nginx/

WORKDIR /app
COPY [".", "/app"]
ENV BUNDLE_GEMFILE /app/Gemfile

RUN mkdir -p tmp/pids
RUN bundle install --without development test --jobs=`cat /proc/cpuinfo | grep processor | wc -l`
RUN bundle exec rake assets:clean && bundle exec rake assets:precompile --jobs=4

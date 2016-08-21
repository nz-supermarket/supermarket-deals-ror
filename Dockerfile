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

# Install Nginx.
RUN apk add --no-cache nginx

# Add configuration to set daemon mode off
CMD ["nginx", "-g", "daemon off;"]
# Add default nginx config
ADD nginx.conf /etc/nginx/sites-enabled/default

WORKDIR /app
COPY [".", "/app"]
ENV BUNDLE_GEMFILE /app/Gemfile

RUN bundle install --local --system --jobs=15 --gemfile=Gemfile
RUN bundle exec rake assets:clean && bundle exec rake assets:precompile --jobs=15
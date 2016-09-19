web: rackup -s Rhebok -O ConfigFile=config/rhebok.rb
nginx: nginx -c /app/nginx.conf
worker: sidekiq -C config/sidekiq.yml
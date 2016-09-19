app: rackup -s Rhebok -O ConfigFile=config/rhebok.rb
web: nginx -c /app/nginx.conf
worker: sidekiq -C config/sidekiq.yml
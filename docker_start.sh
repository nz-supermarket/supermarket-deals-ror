#!/bin/sh
sidekiq &
rackup -s Rhebok -O ConfigFile=config/rhebok.rb
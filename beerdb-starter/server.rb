# encoding: utf-8

require './config/boot'

## -- for thin web server use:
## Rack::Handler::Thin.run StarterApp, :Port => 9292

Rack::Handler::WEBrick.run StarterApp, :Port => 9292

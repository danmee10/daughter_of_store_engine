# This file is used by Rack-based servers to start the application.

require File.expand_path('../config/environment',  __FILE__)
run unicorn_rails

run StoreEngine::Application

$stdout.sync = true


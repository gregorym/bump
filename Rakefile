require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require File.expand_path('../lib/bump/tasks', __FILE__)

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

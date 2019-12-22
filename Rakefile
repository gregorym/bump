# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/gem_tasks'
require 'bump/tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--color'
end

RuboCop::RakeTask.new

task default: [:spec, :rubocop]

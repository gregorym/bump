# frozen_string_literal: true

require "bundler/setup"
require "rspec/support/spec/shell_out"
require "bump"

module SpecHelpers
  module InstanceMethods
    def write(file, content)
      folder = File.dirname(file)
      run "mkdir -p #{folder}" unless File.exist?(folder)
      File.write(file, content)
    end

    def read(file)
      File.read(file)
    end

    def run(cmd, options = {})
      result = `#{cmd} 2>&1`
      raise "FAILED #{cmd} --> #{result}" if $?.success? != !options[:fail]

      result
    end
  end

  module ClassMethods
    def inside_of_folder(folder)
      folder = File.expand_path(folder, File.dirname(File.dirname(__FILE__)))
      around do |example|
        run "rm -rf #{folder} && mkdir #{folder}"
        Dir.chdir folder do
          `git init && git commit --allow-empty -am 'initial'` # so we never accidentally do commit to the current repo
          example.call
        end
        run "rm -rf #{folder}"
      end
    end
  end
end

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }
  config.include SpecHelpers::InstanceMethods
  config.include RSpec::Support::ShellOut
  config.extend SpecHelpers::ClassMethods
end

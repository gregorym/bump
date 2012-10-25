require "bundler"
require "bump"

module SpecHelpers
  module InstanceMethods
    def write(file, content)
      folder = File.dirname(file)
      run "mkdir -p #{folder}" unless File.exist?(folder)
      File.open(file, 'w'){|f| f.write content }
    end

    def read(file)
      File.read(file)
    end

    def run(cmd, options={})
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

RSpec.configure do |c|
  c.include SpecHelpers::InstanceMethods
  c.extend SpecHelpers::ClassMethods
end

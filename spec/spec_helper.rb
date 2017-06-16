require "bundler/setup"
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

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.include SpecHelpers::InstanceMethods
  config.extend SpecHelpers::ClassMethods

  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.warnings = true
  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.syntax = :should
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

end

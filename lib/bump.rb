require 'bump/finders/generic_file'
require 'bump/finders/chef'
require 'bump/finders/gemspec'
require 'bump/finders/lib_rb'

module Bump
  class InvalidOptionError < StandardError; end
  class InvalidVersionError < StandardError; end
  class UnfoundVersionError < StandardError; end
  class TooManyVersionFilesError < StandardError; end
  class UnfoundVersionFileError < StandardError; end

  PRERELEASE    = ["alpha","beta","rc",nil]
  VERSION_REGEX = /(\d+\.\d+\.\d+(?:-(?:#{PRERELEASE.compact.join('|')}))?)/


  class Bump
    BUMPS         = %w(major minor patch pre)

    OPTIONS       = BUMPS | ["set", "current"]

    def self.defaults
      {
        :commit => true,
        :bundle => File.exist?("Gemfile"),
        :tag => false
      }
    end

    def self.run(bump, options={})
      options = defaults.merge(options)

      case bump
      when *BUMPS
        bump_part(bump, options)
      when "set"
        raise InvalidVersionError unless options[:version]
        bump_set(options[:version], options)
      when "current"
        ["Current version: #{current}", 0]
      else
        raise InvalidOptionError
      end
    rescue InvalidOptionError
      ["Invalid option. Choose between #{OPTIONS.join(',')}.", 1]
    rescue InvalidVersionError
      ["Invalid version number given.", 1]
    rescue UnfoundVersionError
      ["Unable to find your gem version", 1]
    rescue UnfoundVersionFileError
      ["Unable to find a file with the gem version", 1]
    rescue TooManyVersionFilesError
      ["More than one gemspec file", 1]
    rescue Exception => e
      ["Something wrong happened: #{e.message}\n#{e.backtrace.join("\n")}", 1]
    end

    def self.current
      current_info.first
    end

    private

    def self.bump(file, current, next_version, options)
      replace(file, current, next_version)
      if options[:bundle] and under_version_control?("Gemfile.lock")
        bundler_with_clean_env do
          system("bundle")
        end
      end
      commit(next_version, file, options) if options[:commit]
      ["Bump version #{current} to #{next_version}", 0]
    end

    def self.bundler_with_clean_env(&block)
      if defined?(Bundler)
        Bundler.with_clean_env(&block)
      else
        yield
      end
    end

    def self.bump_part(part, options)
      current, file = current_info
      next_version = next_version(current, part)
      bump(file, current, next_version, options)
    end

    def self.bump_set(next_version, options)
      current, file = current_info
      bump(file, current, next_version, options)
    end

    def self.commit(version, file, options)
      return unless File.directory?(".git")
      system("git add --update Gemfile.lock") if options[:bundle]
      system("git add --update #{file} && git commit -m 'v#{version}'")
      system("git tag -a -m 'Bump to v#{version}' v#{version}") if options[:tag]
    end

    def self.replace(file, old, new)
      content = File.read(file)
      File.open(file, "w"){|f| f.write(content.sub(old, new)) }
    end

    def self.current_info
      version, file = (
        version_from_version ||
        version_from_version_rb ||
        version_from_gemspec ||
        version_from_lib_rb  ||
        version_from_chef  ||
        raise(UnfoundVersionFileError)
      )
      raise UnfoundVersionError unless version
      [version, file]
    end

    def self.version_from_gemspec
      Finders::Gemspec.new.match
    end

    def self.version_from_version_rb
      Finders::GenericFile.new("lib/**/version.rb").match
    end

    def self.version_from_version
      Finders::GenericFile.new("VERSION").match
    end

    def self.version_from_lib_rb
      Finders::LibRb.new.match
    end

    def self.version_from_chef
      Finders::Chef.new.match
    end

    def self.next_version(current, part)
      current, prerelease = current.split('-')
      major, minor, patch, *other = current.split('.')
      case part
      when "major"
        major, minor, patch, prerelease = major.succ, 0, 0, nil
      when "minor"
        minor, patch, prerelease = minor.succ, 0, nil
      when "patch"
        patch = patch.succ
      when "pre"
        prerelease.strip! if prerelease.respond_to? :strip
        prerelease = PRERELEASE[PRERELEASE.index(prerelease).succ % PRERELEASE.length]
      else
        raise "unknown part #{part.inspect}"
      end
      version = [major, minor, patch, *other].compact.join('.')
      [version, prerelease].compact.join('-')
    end

    def self.under_version_control?(file)
      @all_files ||= `git ls-files`.split(/\r?\n/)
      @all_files.include?(file)
    end

  end
end


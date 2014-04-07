require 'bump/finders/generic_file'
require 'bump/finders/chef'
require 'bump/finders/gemspec'
require 'bump/finders/lib_rb'

module Bump
  extend self

  class InvalidOptionError < StandardError; end
  class InvalidVersionError < StandardError; end
  class UnfoundVersionError < StandardError; end
  class TooManyVersionFilesError < StandardError; end
  class UnfoundVersionFileError < StandardError; end

  PRERELEASE    = ["alpha","beta","rc",nil]
  VERSION_REGEX = /(\d+\.\d+\.\d+(?:-(?:#{PRERELEASE.compact.join('|')}))?)/


  BUMPS         = %w(major minor patch pre)
  OPTIONS       = BUMPS | ["set", "current"]

  def defaults
    {
      :commit => true,
      :bundle => File.exist?("Gemfile"),
      :tag => false
    }
  end

  def run(bump, options={})
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

  def current
    current_info.first
  end

  private

  def bump(file, current, next_version, options)
    replace(file, current, next_version)
    if options[:bundle] and under_version_control?("Gemfile.lock")
      bundler_with_clean_env do
        system("bundle")
      end
    end
    commit(next_version, file, options) if options[:commit]
    ["Bump version #{current} to #{next_version}", 0]
  end

  def bundler_with_clean_env(&block)
    if defined?(Bundler)
      Bundler.with_clean_env(&block)
    else
      yield
    end
  end

  def bump_part(part, options)
    current, file = current_info
    next_version = next_version(current, part)
    bump(file, current, next_version, options)
  end

  def bump_set(next_version, options)
    current, file = current_info
    bump(file, current, next_version, options)
  end

  def commit(version, file, options)
    return unless File.directory?(".git")
    system("git add --update Gemfile.lock") if options[:bundle]
    system("git add --update #{file} && git commit -m 'v#{version}'")
    system("git tag -a -m 'Bump to v#{version}' v#{version}") if options[:tag]
  end

  def replace(file, old, new)
    content = File.read(file)
    File.open(file, "w"){|f| f.write(content.sub(old, new)) }
  end

  def current_info
    version, file = version_finders.map(&:match).compact.first
    raise UnfoundVersionFileError unless file
    raise UnfoundVersionError unless version
    [version, file]
  end

  def version_finders
    [
      Finders::GenericFile.new("VERSION"),
      Finders::GenericFile.new("lib/**/version.rb"),
      Finders::Gemspec.new,
      Finders::LibRb.new,
      Finders::Chef.new
    ]
  end

  def next_version(current, part)
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

  def under_version_control?(file)
    @all_files ||= `git ls-files`.split(/\r?\n/)
    @all_files.include?(file)
  end

end
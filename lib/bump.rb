module Bump
  class InvalidOptionError < StandardError; end
  class UnfoundVersionError < StandardError; end
  class TooManyVersionFilesError < StandardError; end
  class UnfoundVersionFileError < StandardError; end

  class Bump
    BUMPS         = %w(major minor patch pre)
    PRERELEASE    = ["alpha","beta","rc",nil]
    OPTIONS       = BUMPS | ["current"]
    VERSION_REGEX = /(\d+\.\d+\.\d+(?:-(?:#{PRERELEASE.compact.join('|')}))?)/

    def self.defaults
      {
        :commit => true,
        :bundle => File.exist?("Gemfile")
      }
    end

    def self.run(bump, options={})
      options = defaults.merge(options)

      case bump
      when *BUMPS
        bump(bump, options)
      when "current"
        ["Current version: #{current}", 0]
      else
        raise InvalidOptionError
      end
    rescue InvalidOptionError
      ["Invalid option. Choose between #{OPTIONS.join(',')}.", 1]
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

    def self.bump(part, options)
      current, file = current_info
      next_version = next_version(current, part)
      replace(file, current, next_version)
      system("bundle") if options[:bundle] and under_version_control?("Gemfile.lock")
      commit(next_version, file, options) if options[:commit]
      ["Bump version #{current} to #{next_version}", 0]
    end

    def self.commit(version, file, options)
      return unless File.directory?(".git")
      system("git add --update Gemfile.lock") if options[:bundle]
      system("git add --update #{file} && git commit -m 'v#{version}'")
    end

    def self.replace(file, old, new)
      content = File.read(file)
      File.open(file, "w"){|f| f.write(content.gsub(old, new)) }
    end

    def self.current_info
      version, file = (
        version_from_version_rb ||
        version_from_gemspec ||
        version_from_version ||
        version_from_lib_rb  ||
        version_from_chef  ||
        raise(UnfoundVersionFileError)
      )
      raise UnfoundVersionError unless version
      [version, file]
    end

    def self.version_from_gemspec
      return unless file    = find_version_file("*.gemspec")
      version               = File.read(file)[/\.version\s*=\s*["']#{VERSION_REGEX}["']/, 1]
      return unless version = File.read(file)[/Gem::Specification.new.+ ["']#{VERSION_REGEX}["']/, 1] if version.nil?
      [version, file]
    end

    def self.version_from_version_rb
      return unless file = find_version_file("lib/**/version.rb")
      extract_version_from_file(file)
    end

    def self.version_from_version
      return unless file = find_version_file("VERSION")
      extract_version_from_file(file)
    end

    def self.version_from_lib_rb
      files = Dir.glob("lib/**/*.rb")
      return unless file = files.detect { |file| File.readlines(file).grep(/^VERSION = (['"])#{VERSION_REGEX}['"]/i) }
      extract_version_from_file(file)
    end

    def self.version_from_chef
      file = find_version_file("metadata.rb")
      return unless file && File.read(file) =~ /^version\s+(['"])(#{VERSION_REGEX})['"]/
      [$2, file]
    end

    def self.extract_version_from_file(file)
      return unless version = File.read(file)[VERSION_REGEX]
      [version, file]
    end

    def self.find_version_file(pattern)
      files = Dir.glob(pattern)
      case files.size
      when 0 then nil
      when 1 then files.first
      else
        raise TooManyVersionFilesError
      end
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

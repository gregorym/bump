module Bump
  class InvalidOptionError < StandardError; end
  class UnfoundVersionError < StandardError; end
  class TooManyVersionFilesError < StandardError; end
  class UnfoundVersionFileError < StandardError; end

  class Bump
    BUMPS = %w(major minor patch)
    OPTIONS = BUMPS | ["current"]
    VERSION_REGEX = /(\d+\.\d+\.\d+)/

    def self.run(bump, options)
      case bump
      when "major", "minor", "patch"
        bump(bump, options)
      when "current"
        current
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

    private

    def self.bump(part, options)
      current, file = current_version
      next_version = next_version(current, part)
      replace(file, current, next_version)
      commit(next_version, file) if options[:commit]
      ["Bump version #{current} to #{next_version}", 0]
    end

    def self.commit(version, file)
      return unless File.directory?(".git")
      raise unless system("git add #{file} && git commit -m 'v#{version}'")
    end

    def self.replace(file, old, new)
      content = File.read(file)
      File.open(file, "w"){|f| f.write(content.gsub(old, new)) }
    end

    def self.current
      ["Current version: #{current_version.first}", 0]
    end

    def self.current_version
      version, file = (
        version_from_version_rb ||
        version_from_gemspec ||
        version_from_version ||
        raise(UnfoundVersionFileError)
      )
      raise UnfoundVersionError unless version
      [version, file]
    end

    def self.version_from_version_rb
      return unless file = find_version_file("*/**/version.rb")
      return unless version = File.read(file)[VERSION_REGEX]
      [version, file]
    end

    def self.version_from_gemspec
      return unless file = find_version_file("*.gemspec")
      return unless version = File.read(file)[/\.version\s*=\s*["']#{VERSION_REGEX}["']/, 1]
      [version, file]
    end

    def self.version_from_version
      return unless file = find_version_file("VERSION")
      return unless version = File.read(file)
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
        major, minor, patch = major.succ, 0, 0
      when "minor"
        minor, patch = minor.succ, 0
      when "patch"
        patch = patch.succ
      else
        raise "unknown part #{part.inspect}"
      end
      version = [major, minor, patch, *other].compact.join('.')
      [version, prerelease].compact.join('-')
    end
  end
end

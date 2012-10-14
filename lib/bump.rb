module Bump
  class InvalidOptionError < StandardError; end
  class UnfoundVersionError < StandardError; end
  class TooManyVersionFilesError < StandardError; end
  class UnfoundVersionFileError < StandardError; end

  class Bump
    attr_accessor :bump
    
    BUMPS = %w(major minor tiny)
    OPTIONS = BUMPS | ["current"]
    VERSION_REGEX = /(\d+\.\d+\.\d+)/

    def initialize(bump)
      @bump = bump.is_a?(Array) ? bump.first : bump
    end

    def run
      case @bump
      when "major", "minor", "tiny"
        bump(@bump)
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
      ["Unable to find gemspec file", 1]
    rescue TooManyVersionFilesError
      ["More than one gemspec file", 1]
    rescue Exception => e
      ["Something wrong happened: #{e.message}\n#{e.backtrace.join("\n")}", 1]
    end

    private

    def bump(part)
      current, file = current_version
      next_version = next_version(current, part)
      replace(file, current, next_version)
      ["Bump version #{current} to #{next_version}", 0]
    end

    def replace(file, old, new)
      content = File.read(file)
      File.open(file, "w"){|f| f.write(content.gsub(old, new)) }
    end

    def current
      ["Current version: #{current_version.first}", 0]
    end

    def current_version
      version, file = version_from_version_rb || version_from_gemspec || raise(UnfoundVersionFileError)
      raise UnfoundVersionError unless version
      [version, file]
    end

    def version_from_version_rb
      return unless file = find_version_file("*/**/version.rb")
      [
        File.read(file)[VERSION_REGEX],
        file
      ]
    end

    def version_from_gemspec
      return unless file = find_version_file("*.gemspec")
      [
        File.read(file)[/\.version\s*=\s*["']#{VERSION_REGEX}["']/, 1],
        file
      ]
    end

    def find_version_file(pattern)
      files = Dir.glob(pattern)
      case files.size
      when 0 then nil
      when 1 then files.first
      else
        raise TooManyVersionFilesError
      end
    end

    def next_version(current, part)
      match = current.match /(\d+)\.(\d+)\.(\d+)/
      case part
      when "major"
        "#{match[1].to_i + 1}.0.0"
      when "minor"
        "#{match[1]}.#{match[2].to_i + 1}.0"
      when "tiny"
        "#{match[1]}.#{match[2]}.#{match[3].to_i + 1}"
      else
        raise "unknown part #{part.inspect}"
      end
    end
  end
end

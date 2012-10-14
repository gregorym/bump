module Bump

  class InvalidOptionError < StandardError; end
  class UnfoundVersionError < StandardError; end
  class TooManyGemspecsFoundError < StandardError; end
  class UnfoundGemspecError < StandardError; end

  class Bump
    
    attr_accessor :bump, :gemspec_path, :version, :next_version
    
    BUMPS = %w(major minor tiny)
    OPTIONS = BUMPS | ["current"]
    VERSION_REGEX = /\.version\s*=\s*["'](\d+\.\d+\.\d+)["']/

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
    rescue UnfoundGemspecError
      ["Unable to find gemspec file", 1]
    rescue TooManyGemspecsFoundError
      ["More than one gemspec file", 1]
    rescue Exception => e
      ["Something wrong happened: #{e.message}", 1]
    end

    private

    def bump(part)
      current = current_version
      next_version = next_version(current, part)
      system(%(ruby -i -pe "gsub(/#{current}/, '#{next_version}')" #{gemspec_path}))
      ["Bump version #{current} to #{next_version}", 0]
    end

    def current
      ["Current version: #{current_version}", 0]
    end

    def current_version
      match = File.read(gemspec_path).match VERSION_REGEX
      if match
        match[1]
      else
        raise UnfoundVersionError
      end
    end

    def gemspec_path
      @gemspec_path ||= begin
        gemspecs = Dir.glob("*.gemspec")
        raise UnfoundGemspecError if gemspecs.size.zero?
        raise TooManyGemspecsFoundError if gemspecs.size > 1
        gemspecs.first
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

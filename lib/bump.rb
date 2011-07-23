module Bump

  class InvalidOptionError < StandardError; end
  class UnfoundVersionError < StandardError; end
  class TooManyGemspecsFoundError < StandardError; end
  class UnfoundGemspecError < StandardError; end

  class Bump
    
    BUMPS = %w(major minor tiny)
    OPTIONS = BUMPS | ["current"]
    VERSION_REGEX = /version\s*=\s*["|'](\d.\d.\d)["|']/

    def initialize(bump)
      @bump = bump.is_a?(Array) ? bump.first : bump
    end

    def run
      begin
        raise InvalidOptionError unless OPTIONS.include?(@bump)

        gemspec = find_gemspec_file
        current_version = find_current_version(gemspec)
        
        case @bump
          when "major", "minor", "tiny"
            bump(current_version, gemspec)
          when "current"
            current(current_version)
          else
            raise Exception
        end
        
        rescue InvalidOptionError
          puts "Invalid option. Choose between #{OPTIONS.join(',')}."
        rescue UnfoundVersionError
          puts "Unable to find your gem version"
        rescue UnfoundGemspecError
          puts "Unable to find gemspec file"
        rescue TooManyGemspecsFoundError
          puts "More than one gemspec file"
        rescue Exception => e
          puts "Something wrong happened: #{e.message}"
      end   
    end

    private

    def bump(current_version, gemspec)
      next_version = find_next_version(current_version)
      system(%(ruby -i -pe "gsub(/#{current_version}/, '#{next_version}')" #{gemspec}))
      puts "Bump version #{current_version} to #{next_version}"
    end

    def current(current_version)
      puts "Current version: #{current_version}"
    end

    def find_current_version(file)
      match = File.read(file).match VERSION_REGEX
      if match.nil?
        raise UnfoundVersionError
      else
        match[1]
      end
    end

    def find_gemspec_file
      gemspecs = Dir.glob("*.gemspec")
      raise UnfoundGemspecError if gemspecs.size.zero?
      raise TooManyGemspecsFoundError if gemspecs.size > 1
      gemspecs.first 
    end

    def find_next_version(current_version)
      match = current_version.match /(\d).(\d).(\d)/
      case @bump
        when "major"
          "#{match[1].to_i + 1}.0.0"
        when "minor"
          "#{match[1]}.#{match[2].to_i + 1}.0"
        when "tiny"
          "#{match[1]}.#{match[2]}.#{match[3].to_i + 1}"
      end
    end 

  end

end

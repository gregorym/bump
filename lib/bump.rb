module Bump

  class Bump
    
    BUMPS = %w(major minor tiny)
    VERSION_REGEX = /version\s*=\s*["|'](\d.\d.\d)["|']/

    class InvalidOptionError < StandardError; end
    class UnfoundVersionError < StandardError; end
    class TooManyGemspecsFoundError < StandardError; end
    class UnfoundGemspecError < StandardError; end

    def initialize(bump)
      @bump = bump.is_a?(Array) ? bump.first : bump
    end

    def run
      begin
        raise InvalidBumpError unless BUMPS.include?(@bump)

        gemspec = find_gemspec_file
        current_version = find_current_version(gemspec)
        next_version = find_next_version(current_version)
        system(%(ruby -i -pe "gsub(/#{current_version}/, '#{next_version}')" #{gemspec}))
        display_message "Bump version #{current_version} to #{next_version}"

        rescue InvalidBumpError
          display_message "Invalid bump. Choose between #{BUMPS.join(',')}."
        rescue UnfoundVersionError
          display_message "Unable to find your gem version"
        rescue UnfoundGemspecError
          display_message "Unable to find gemspec file"
        rescue TooManyGemspecsFoundError
          display_message "More than one gemspec file"
        rescue Exception => e
          display_message "Something wrong happened: #{e.message}"
      end   
    end

    private

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

    def display_message(message)
      print(message); puts;
    end

  end

end

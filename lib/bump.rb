module Bump

  class Bump
    
    BUMPS = %w(major minor tiny)

    class InvalidBumpError < StandardError; end
    class UnfoundVersionError < StandardError; end
    class TooManyGemspecsFoundError < StandardError; end
    class UnfoundGemspecError < StandardError; end

    def initialize(bump)
      begin
        bump = bump.is_a?(Array) ? bump.first : bump
        raise InvalidBumpError unless BUMPS.include?(bump)
        @bump = bump

        rescue InvalidBumpError
          print "Invalid bump. Choose between #{BUMPS.join(',')}."
        rescue Exception
          print "Something wrong happened"
      end
    end

    def run
      begin
        gemspec = find_gemspec_file
        current_version = find_current_version(gemspec)
        next_version = find_next_version(current_version)
        system(%(ruby -i -pe "gsub(/#{current_version}/, '#{next_version}')" #{gemspec}))
        print "Bump version #{current_version} to #{next_version}"

        rescue UnfoundVersionError
          print "Unable to find your gem version"
        rescue UnfoundGemspecError
          print "Unable to find gemspec file"
        rescue TooManyGemspecsFoundError
          print "More than one gemspec file"
      end   
    end

    private

    def find_current_version(file)
      match = File.read(file).match /version\s*=\s*"(\d.\d.\d)"/
      raise UnfoundVersionError if match.blank?
      match[1]
    end

    def find_gemspec_file
      gemspecs = Dir.glob("*.gemspec")
      raise UnfoundGemspecError if gemspecs.size.zero?
      raise TooManyGemspecsFoundError if gemspecs.size > 1
      gemspecs.first 
    end

    def find_next_version(current_version)
      match = current_version.match(/(\d).(\d).(\d)/)
      case @bump
        when "major"
          "#{match[1].to_i + 1}.0.0"; puts
        when "minor"
          "#{match[1]}.#{match[2].to_i + 1}.0"; puts
        when "tiny"
          "#{match[1]}.#{match[2]}.#{match[3].to_i + 1}"; puts
      end
    end 

  end

end

module Bump
  class InvalidOptionError < StandardError; end
  class UnfoundVersionError < StandardError; end
  class TooManyVersionFilesError < StandardError; end
  class UnfoundVersionFileError < StandardError; end

  class Bump
    BUMPS = %w(major minor patch pre)
    PRERELEASE = ["alpha","beta","rc",nil]
    OPTIONS = BUMPS | ["current"]
    VERSION_REGEX = /(\d+\.\d+\.\d+(?:-(?:#{PRERELEASE.compact.join('|')}))?)/

    def self.run(bump, options)
      case bump
      when *BUMPS
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

    # Private: Bump the current gem version
    #
    # part    -zone of the version to bump
    # options -Options
    #
    # Returns a string the old and the new gem version
    def self.bump(part, options)
      current, file = current_version
      next_version = next_version(current, part)
      replace(file, current, next_version)
      system("bundle") if options[:bundle]
      commit(next_version, file, options) if options[:commit]
      ["Bump version #{current} to #{next_version}", 0]
    end

    # Private: Commit changes
    #
    # version -New version of the gem
    # file    -File to add to Git
    # options -Options
    #
    # Returns the duplicated String.
    def self.commit(version, file, options)
      return unless File.directory?(".git")
      system("git add --update Gemfile.lock") if options[:bundle]
      system("git add --update #{file} && git commit -m 'v#{version}'")
    end

    
    # Private: Replace the old version with the new one in the given file
    #
    # file -File where replacement will happen
    # old  -old gem version
    # new  -new gem version
    #
    def self.replace(file, old, new)
      content = File.read(file)
      File.open(file, "w"){|f| f.write(content.gsub(old, new)) }
    end

    
    # Private: Current version of the gem
    #
    # Returns the gem version
    def self.current
      ["Current version: #{current_version.first}", 0]
    end

    # Private: Find the current gem version from different source
    #
    # Returns the gem version and the file containing the version
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

    
    # Private: Find the gem version for version.rb
    #
    # Returns the gem version and file
    def self.version_from_version_rb
      return unless file = find_version_file("*/**/version.rb")
      return unless version = File.read(file)[VERSION_REGEX]
      [version, file]
    end

    # Private: Find the gem version for the gemspec
    #
    # Returns the gem version and file
    def self.version_from_gemspec
      return unless file = find_version_file("*.gemspec")
      return unless version = File.read(file)[/\.version\s*=\s*["']#{VERSION_REGEX}["']/, 1]
      [version, file]
    end
    
    # Private: find the gem version from version
    #
    # Returns the version and the file
    def self.version_from_version
      return unless file = find_version_file("VERSION")
      return unless version = File.read(file)[VERSION_REGEX]
      [version, file]
    end
    
    # Private: Find file from given regex
    #
    # pattern -Regular expression
    #
    # Returns a file
    def self.find_version_file(pattern)
      files = Dir.glob(pattern)
      case files.size
      when 0 then nil
      when 1 then files.first
      else
        raise TooManyVersionFilesError
      end
    end

    
    # Private: Compute the new gem version 
    #
    # current -current gem version
    # part    -zone of the version to bump
    #
    # Returns the new gem version
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
  end
end

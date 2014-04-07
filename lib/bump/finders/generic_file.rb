module Bump
  module Finders
    class GenericFile
      attr_accessor :file_name

      def initialize(file_name="")
        @file_name = file_name
      end

      # Returns string containing matched file name
      def file
        @file ||= find_version_file
      end

      # Find a compatible version string in the file
      def version
        @version ||= File.read(file)[version_regex]
      end

      # Returns the version and file strings in an array, or nil if missing
      def match
        [version, file] if file && version
      end

    private

      # Returns a single file that matches the file_name, returns nil if no
      # files found, or TooManyVersionFilesError if more than one found
      def find_version_file
        files = Dir.glob(file_name)
        case files.size
        when 0 then nil
        when 1 then files.first
        else
          raise TooManyVersionFilesError
        end
      end

      def version_regex
        ::Bump::VERSION_REGEX
      end
    end
  end
end
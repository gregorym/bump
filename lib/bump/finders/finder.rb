module Bump
  module Finders
    class Finder
      attr_accessor :file_name

      def initialize(path="")
        @file_name = path
      end

      def version_regex
        ::Bump::VERSION_REGEX
      end

      def find_version_file
        files = Dir.glob(file_name)
        case files.size
        when 0 then nil
        when 1 then files.first
        else
          raise TooManyVersionFilesError
        end
      end

      def file
        @file ||= find_version_file
      end

      def version
        @version ||= File.read(file)[version_regex] if file
      end

      def match
        return unless version
        [version, file]
      end
    end
  end
end
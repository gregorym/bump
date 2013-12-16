module Bump
  module Finders
    class Finder
      attr_accessor :file_name

      def initialize(file_name="")
        @file_name = file_name
      end

      def file
        @file ||= find_version_file
      end

      def version
        @version ||= File.read(file)[version_regex] if file
      end

      def match
        [version, file] if file && version
      end

    private

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
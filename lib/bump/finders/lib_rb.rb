module Bump
  module Finders
    class LibRb < Bump::Finders::GenericFile

      # Finds the first file that has a compatible VERSION constant
      def file
        @file ||= Dir.glob("lib/**/*.rb").detect { |f| find_version(f) }
      end

      # Find a compatible version string in the file
      def version
        @version ||= find_version(file)[1]
      end

    private

      # Reads file and returns a version regex match
      def find_version(file)
        File.read(file).match /^\s+VERSION = ['"](#{version_regex})['"]/i
      end
    end
  end
end

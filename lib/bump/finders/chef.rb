module Bump
  module Finders
    class Chef < Bump::Finders::Finder
      def file_name
        "metadata.rb"
      end

      def version
        File.read(file).match(/^version\s+(['"])(#{version_regex})['"]/)[0]
      end

      def match
        return unless file
        [version, file]
      end
    end
  end
end

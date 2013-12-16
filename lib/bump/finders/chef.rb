module Bump
  module Finders
    class Chef < Bump::Finders::Finder
      def version
        File.read(file).match(/^version\s+(['"])(#{version_regex})['"]/)[0]
      end

    private

      def file_name
        "metadata.rb"
      end
    end
  end
end

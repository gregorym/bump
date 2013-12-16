module Bump
  module Finders
    class LibRb < Bump::Finders::Finder
      attr_accessor :version

      def file
        @file ||= begin
          Dir.glob("lib/**/*.rb").detect do |f|
            match = File.read(f).match /^\s+VERSION = ['"](#{version_regex})['"]/i
            self.version = match[1] if match
            match
          end
        end
      end
    end
  end
end

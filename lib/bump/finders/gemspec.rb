module Bump
  module Finders
    class Gemspec < Bump::Finders::Finder
      def file_name
        "*.gemspec"
      end

      def gemspec
        @gemspec ||= File.read(file)
      end

      def version
        gemspec[/\.version\s*=\s*["']#{version_regex}["']/, 1] ||
          gemspec[/Gem::Specification.new.+ ["']#{version_regex}["']/, 1]
      end

      def match
        return unless file
        return unless version
        [version, file]
      end
    end
  end
end
module Bump
  module Finders
    class Gemspec < Bump::Finders::Finder
      def version
        gemspec = File.read(file)
        gemspec[/\.version\s*=\s*["']#{version_regex}["']/, 1] ||
          gemspec[/Gem::Specification.new.+ ["']#{version_regex}["']/, 1]
      end

    private

      def file_name
        "*.gemspec"
      end
    end
  end
end
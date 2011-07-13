Gem::Specification.new do |s|
  s.name = "bump"
  s.version = "0.1.2"
  s.author = "Gregory Marcilhacy"
  s.email = "g.marcilhacy@gmail.com"
  s.homepage = "http://github.com/gregorymp/bump"
  s.summary = "Bump your gem version file"

  s.files = %w(
    README.textile
    bump.gemspec
    bin/bump
    lib/bump.rb
  )
  
  s.require_path = "lib"
  s.executables = ["bump"]

end



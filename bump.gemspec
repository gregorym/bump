Gem::Specification.new "bump" do |s|
  s.version = "0.5.0"
  s.author = "Gregory Marcilhacy"
  s.email = "g.marcilhacy@gmail.com"
  s.homepage = "https://github.com/gregorym/bump"
  s.summary = "Bump your gem version file"

  s.files = `git ls-files`.split("\n")
  s.license = "MIT"
  s.require_path = "lib"
  s.executables = ["bump"]

  s.add_development_dependency 'rake', '~> 10.0.0'
  s.add_development_dependency 'rspec', '~> 2.0'
end



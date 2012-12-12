Gem::Specification.new "bump" do |s|
  s.version = "0.3.7"
  s.author = "Gregory Marcilhacy"
  s.email = "g.marcilhacy@gmail.com"
  s.homepage = "https://github.com/gregorym/bump"
  s.summary = "Bump your gem version file"

  s.files = `git ls-files`.split("\n")
  s.license = "MIT"
  s.require_path = "lib"
  s.executables = ["bump"]

  s.add_development_dependency 'rake', '~> 10.0.2'
  s.add_development_dependency 'bundler', '~> 1.2.3'
  s.add_development_dependency 'rspec', '~> 2.11.0'
end



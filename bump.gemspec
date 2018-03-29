Gem::Specification.new "bump" do |s|
  s.version = "0.6.0"
  s.author = "Gregory Marcilhacy"
  s.email = "g.marcilhacy@gmail.com"
  s.homepage = "https://github.com/gregorym/bump"
  s.summary = "Bump your gem version file"
  s.required_ruby_version = '>= 1.9.3'

  s.files = `git ls-files lib README.md`.split("\n")
  s.license = "MIT"
  s.executables = ["bump"]

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
end

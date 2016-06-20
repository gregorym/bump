Gem::Specification.new "bump" do |s|
  s.version = "0.5.5"
  s.author = "Gregory Marcilhacy"
  s.email = "g.marcilhacy@gmail.com"
  s.homepage = "https://github.com/gregorym/bump"
  s.summary = "Bump your gem version file"
  s.required_ruby_version = '>= 1.9.3'

  s.files = `git ls-files lib README.md`.split("\n")
  s.license = "MIT"
  s.executables = ["bump"]

  s.add_development_dependency 'rake', '~> 10.0.0'
  s.add_development_dependency 'rspec', '~> 2.0'
  s.add_development_dependency 'berkshelf', '~> 4.0'
end



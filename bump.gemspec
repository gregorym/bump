# frozen_string_literal: true

Gem::Specification.new "bump" do |s|
  s.version = "0.10.0"
  s.author = "Gregory Marcilhacy"
  s.email = "g.marcilhacy@gmail.com"
  s.homepage = "https://github.com/gregorym/bump"
  s.summary = "Bump your gem version file"
  s.required_ruby_version = '>= 2.7.0'

  s.files = `git ls-files lib README.md`.split("\n")
  s.license = "MIT"
  s.executables = ["bump"]
end

Gem::Specification.new do |s|
  s.name = "bump"
  s.version = "0.1.3"
  s.author = "Gregory Marcilhacy"
  s.email = "g.marcilhacy@gmail.com"
  s.homepage = "https://github.com/gregorym/bump"
  s.summary = "Bump your gem version file"

  s.files = %w(
    README.textile
    bump.gemspec
    bin/bump
    lib/bump.rb
  )

  s.test_files = %w(
    test/bump_spec.rb
    test/fixture/fixture.gemspec
  )

  s.require_path = "lib"
  s.executables = ["bump"]

end



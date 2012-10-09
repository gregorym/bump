Gem::Specification.new "bump" do |s|
  s.version = "0.1.3"
  s.author = "Gregory Marcilhacy"
  s.email = "g.marcilhacy@gmail.com"
  s.homepage = "https://github.com/gregorym/bump"
  s.summary = "Bump your gem version file"

  s.files = `git ls-files`.split("\n")
  s.license = "MIT"
  s.require_path = "lib"
  s.executables = ["bump"]
end



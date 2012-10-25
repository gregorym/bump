# Installation

    gem install bump

# Usage

Current version of your gem:

    bump current

Current version: 0.1.2

Bump your gemfile (major, minor, patch):

    bump patch

Bump version 0.1.2 to 0.1.3

### Rake

```Ruby
# Rakefile
require "bump/tasks"
```

    rake bump:patch
    rake bump:current

# Supported locations
 - VERSION file with "1.2.3"
 - gemspec with `gem.version = "1.2.3"`
 - lib/**/version.rb file with `VERSION = "1.2.3"`

# Todo

 - Handle options properly
 - `VERSION = "1.2.3"` in lib/*.rb
 - gemspec with `Gem::Specification.new "gem-name", "1.2.3" do`

# Author
Gregory<br/>
License: MIT<br/>
[![Build Status](https://travis-ci.org/gregorym/bump.png)](https://travis-ci.org/gregorym/bump)



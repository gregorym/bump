# Introduction
Bump is a gem that will simplify the way you build gems. 


# Installation

    gem install bump

# Usage

Current version of your gem:

    bump current

Current version: 0.1.2

Bump your gemfile (major, minor, patch, pre):

    bump patch

Bump version 0.1.2 to 0.1.3

### Options

    bump patch --no-commit

    bump patch --no-bundle

### Rake

```Ruby
# Rakefile
require "bump/tasks"
```

    rake bump:patch
    rake bump:current

### Ruby
```Ruby
require "bump"
Bump::Bump.run("patch")   # -> version changed
Bump::Bump.current        # -> "1.2.3"
```

# Supported locations
 - VERSION file with "1.2.3"
 - gemspec with `gem.version = "1.2.3"` or `Gem:Specification.new "gem-name", "1.2.3" do`
 - lib/**/version.rb file with `VERSION = "1.2.3"`

# Todo

 - Handle options properly
 - `VERSION = "1.2.3"` in lib/*.rb
 - Build new gem version: gem build xxx.gemspec

# Author
Gregory<br/>
License: MIT<br/>
[![Build Status](https://travis-ci.org/gregorym/bump.png)](https://travis-ci.org/gregorym/bump)



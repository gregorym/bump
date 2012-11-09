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

### --no-commit
If you don't want to make a commit after bumping your gem, add the `--no-commit` option.
    
    bump patch --no-commit


### --no-bundle
If you don't want to run the `bundle` command after bumping your gem, add the `--no-bundle` option.
    
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

 - `VERSION = "1.2.3"` in lib/*.rb

# Author
Gregory<br/>
License: MIT<br/>
[![Build Status](https://travis-ci.org/gregorym/bump.png)](https://travis-ci.org/gregorym/bump)



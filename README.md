[![Build Status](https://travis-ci.org/gregorym/bump.svg)](https://travis-ci.org/gregorym/bump)
[![Gem Version](https://badge.fury.io/rb/bump.svg)](http://badge.fury.io/rb/bump)

# Introduction
Bump is a gem that will simplify the way you build gems and chef-cookbooks.


# Installation

    gem install bump

# Usage

Current version:

    bump current

Current version: 0.1.2

Bump (major, minor, patch, pre):

    bump patch

Bump version 0.1.2 to 0.1.3

### Options

### --no-commit
If you don't want to make a commit after bumping, add the `--no-commit` option.
    
    bump patch --no-commit

### --tag
Will add a git tag (if the current project is a git repository and `--no-commit` has not been given).

    bump patch --tag

### --no-bundle
If you don't want to run the `bundle` command after bumping, add the `--no-bundle` option.
    
    bump patch --no-bundle

### --commit-message [MSG], -m [MSG]
If you want to append additional information to the commit message, pass it in using the `--commit-message [MSG]` or `-m [MSG]` option.

    bump patch --commit-message [no-ci]

or

    bump patch -m [no-cli]

### Rake

```Ruby
# Rakefile
require "bump/tasks"

#
# if you want to always tag the verison, add:
# Bump.tag_by_default = true
#

```

    rake bump:patch
    rake bump:current

### Ruby
```Ruby
require "bump"
Bump::Bump.current        # -> "1.2.3"
Bump::Bump.run("patch")   # -> version changed
Bump::Bump.run("patch", commit: false, bundle:false, tag:false) # -> version changed with options
Bump::Bump.run("patch", commit_message: '[no ci]') # -> creates a commit message with 'v1.2.3 [no ci]' instead of default: 'v1.2.3'
```

# Supported locations
 - VERSION file with "1.2.3"
 - gemspec with `gem.version = "1.2.3"` or `Gem:Specification.new "gem-name", "1.2.3" do`
 - lib/**/version.rb file with `VERSION = "1.2.3"`
 - metadata.rb with `version "1.2.3"`
 - `VERSION = "1.2.3"` in lib/**/*.rb

# Author
Gregory<br/>
License: MIT<br/>

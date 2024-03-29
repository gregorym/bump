# frozen_string_literal: true

require "spec_helper"
require "tempfile"

describe Bump do
  let(:gemspec) { "fixture.gemspec" }

  inside_of_folder("spec/fixture")

  it "should fail if it cannot find anything to bump" do
    bump("current", fail: true).should include "Unable to find"
  end

  it "should fail if invalid increment was given" do
    bump("show-next wrong", fail: true).should include "Invalid increment"
  end

  it "should fail if it cannot find version file" do
    bump("file", fail: true).should include "Unable to find"
  end

  it "should fail without command" do
    write_gemspec
    bump("", fail: true).should include "Usage instructions: bump --help"
  end

  it "should fail with invalid options" do
    write_gemspec
    bump("xxx", fail: true).should include "Invalid option"
  end

  it "should fail with multiple gemspecs" do
    write_gemspec
    write("xxxx.gemspec", "Gem::Specification.new{}")
    result = bump("current", fail: true)
    result.should include "More than one version file found"
    result.should include "fixture.gemspec"
    result.should include "xxxx.gemspec"
  end

  it "should fail if version is weird" do
    write_gemspec('"1."+"3.4"')
    bump("current", fail: true).should include "Unable to find a file with the gem version"
  end

  it "should show help" do
    bump("--help").should include("bump current")
  end

  context "git" do
    it "should commit the new version" do
      write_gemspec
      `git add #{gemspec}`

      bump("patch")

      `git log -1 --pretty=format:'%s'`.should == "v4.2.4"
      `git status`.should include "nothing to commit"
    end

    it "should append commit message if --commit-message flag was given" do
      write_gemspec
      `git add #{gemspec}`

      bump("patch --commit-message 'Commit message.'")

      `git log -1 --pretty=format:'%s'`.should include "Commit message."
      `git status`.should include "nothing to commit"
    end

    it "should append commit message if -m flag gas given" do
      write_gemspec
      `git add #{gemspec}`

      bump("patch -m 'Commit message.'")

      `git log -1 --pretty=format:'%s'`.should include "Commit message."
      `git status`.should include "nothing to commit"
    end

    it "should add tag to commit message if %<tag> placeholder was in message" do
      write_gemspec
      `git add #{gemspec}`

      bump("patch -m 'Commit message. %<tag>'")

      `git log -1 --pretty=format:'%s'`.should include 'Commit message. v4.2.4'
    end

    it "should not commit if --no-commit flag was given" do
      write_gemspec
      `git add #{gemspec}`

      bump("patch --no-commit")

      `git log -1 --pretty=format:'%s'`.should == "initial"
      `git status`.should_not include "nothing to commit"
    end

    it "should not add untracked gemspec" do
      write_gemspec

      bump("patch")

      `git log -1 --pretty=format:'%s'`.should == "initial"
      `git status`.should include "Untracked files:"
    end

    it "should tag the version with default prefix 'v' if --tag flag given and --tag-prefix is not given" do
      write_gemspec

      bump("patch --tag")
      `git tag -l`.should include 'v4.2.4'
    end

    it "should tag the version without any prefix if --tag flag given and --tag-prefix is ''" do
      write_gemspec

      bump('patch --tag --tag-prefix ""')
      `git tag -l`.should include '4.2.4'
    end

    it "should tag the version with the given prefix value if --tag flag given and --tag-prefix is passed with a value" do
      write_gemspec

      bump("patch --tag --tag-prefix v-")
      `git tag -l`.should include 'v-4.2.4'
    end

    it "should not tag the version if --no-commit and --tag flag given" do
      write_gemspec

      bump("patch --no-commit --tag")
      `git tag -l`.should == ''
    end
  end

  context ".version in gemspec" do
    before do
      write_gemspec
    end

    it "should find current version" do
      bump("current").should eq("4.2.3\n")
      read(gemspec).should include('s.version = "4.2.3"')
    end

    it "should show next patch version" do
      bump("show-next patch").should include("4.2.4")
    end

    it "should find version file" do
      bump("file").should eq("fixture.gemspec\n")
    end

    it "should bump patch" do
      bump("patch").should include("4.2.4")
      read(gemspec).should include('s.version = "4.2.4"')
    end

    it "should bump minor" do
      bump("minor").should include("4.3.0")
      read(gemspec).should include('s.version = "4.3.0"')
    end

    it "should bump major" do
      bump("major").should include("5.0.0")
      read(gemspec).should include('s.version = "5.0.0"')
    end

    it "should set the version" do
      bump("set 1.2.3").should include("1.2.3")
      read(gemspec).should include('s.version = "1.2.3"')
    end

    it "should bump more then 10" do
      bump("patch").should include("4.2.4")
      bump("patch").should include("4.2.5")
      bump("patch").should include("4.2.6")
      bump("patch").should include("4.2.7")
      bump("patch").should include("4.2.8")
      bump("patch").should include("4.2.9")
      bump("patch").should include("4.2.10")
      bump("patch").should include("4.2.11")
      read(gemspec).should include('s.version = "4.2.11"')
    end

    it "should not bump multiple versions" do
      version = '"4.2.3"'
      write gemspec, <<-RUBY
        Gem::Specification.new do |s|
          s.name    = 'fixture'
          s.version = #{version}
          s.summary = 'Fixture gem'
          s.runtime_dependency 'rake', #{version}
        end
      RUBY
      bump("patch").should include("4.2.4")
      read(gemspec).should include('s.version = "4.2.4"')
      read(gemspec).should include("'rake', #{version}")
    end

    it "can bump in additional files" do
      with_file "Readme.md", "X4.2.3Y" do
        bump("patch --replace-in Readme.md").should include("4.2.4")
        read("Readme.md").should include("X4.2.4Y")
      end
    end

    it "fails when asked to bump in missing additional files" do
      bump("patch --replace-in Readme.md", fail: true)
    end
  end

  context ".version in gemspec within the initializer" do
    before do
      write gemspec, <<-RUBY.sub(" " * 6, "")
        Gem::Specification.new "bump", "4.2.3" do
        end
      RUBY
    end

    it "should bump patch" do
      bump("patch").should include("4.2.4")
      read(gemspec).should include('"4.2.4"')
    end

    it "should set the version" do
      bump("set 1.2.3").should include("1.2.3")
      read(gemspec).should include('"1.2.3"')
    end
  end

  context "VERSION in version.rb" do
    let(:version_file) { "lib/foo/version.rb" }

    before do
      write_version_file
    end

    it "show current" do
      bump("current").should include("1.2.3")
      read(version_file).should include('  VERSION = "1.2.3"')
    end

    it "show next minor version" do
      bump("show-next minor").should include("1.3.0")
    end

    it "show file path" do
      output = bump("file")
      output.should include(version_file)
      read(version_file).should include("VERSION = ")
    end

    it "allows multiple" do
      Dir.mkdir "lib/foo/client"
      File.write("lib/foo/client/version.rb", "SomethingElse")
      bump("current").should include("1.2.3")
    end

    it "should bump VERSION" do
      bump("minor").should include("1.3.0")
      read(version_file).should include('  VERSION = "1.3.0"')
    end

    it "should set the version" do
      bump("set 1.2.3").should include("1.2.3")
      read(version_file).should include('"1.2.3"')
    end

    it "should bump Version" do
      write version_file, <<-RUBY.sub(" " * 8, "")
        module Foo
          Version = "1.2.3"
        end
      RUBY
      bump("minor").should include("1.3.0")
      read(version_file).should include('  Version = "1.3.0"')
    end

    it "should set Version" do
      write version_file, <<-RUBY.sub(" " * 8, "")
        module Foo
          Version = "1.2.3"
        end
      RUBY
      bump("set 1.3.0").should include("1.3.0")
      read(version_file).should include('  Version = "1.3.0"')
    end

    it "should bump if a gemspec exists and leave it alone" do
      write_gemspec "'1.'+'2.3'"
      bump("minor").should include("1.3.0")
      read(gemspec).should include("version = '1.'+'2.3'")
    end
  end

  context "version in VERSION" do
    let(:version) { "1.2.3" }
    let(:version_file) { "lib/foo/version.rb" }

    before do
      write "VERSION", "#{version}\n"
    end

    it "show current" do
      bump("current").should include(version)
      read("VERSION").should include(version)
    end

    it "show next major version" do
      bump("show-next major").should include("2.0.0")
    end

    it "show file" do
      bump("file").should include("VERSION")
    end

    it "should bump version" do
      bump("minor").should include("1.3.0")
      read("VERSION").should include("1.3.0")
    end

    it "should set the version" do
      bump("set 1.3.0").should include("1.3.0")
      read("VERSION").should include("1.3.0")
    end

    it "should bump if a gemspec & version.rb exists and leave it alone" do
      write_gemspec "'1.2.0'"
      write_version_file "File.read('VERSION')"
      bump("minor").should include("1.3.0")
      read("VERSION").should include("1.3.0")
      read(version_file).should include("VERSION = File.read('VERSION')")
      read(gemspec).should include("version = '1.2.0'")
    end

    context "with pre-release identifier" do
      let(:version) { "1.2.3-alpha" }
      before do
        write "VERSION", "#{version}\n"
      end

      it "show current" do
        bump("current").should include(version)
        read("VERSION").should include(version)
      end

      it "show next pre-release version" do
        bump("show-next pre").should include("1.2.3-beta")
      end

      it "show file path" do
        bump("file").should include("VERSION")
      end

      it "minor should drop prerelease" do
        bump("minor").should include("1.3.0")
        read("VERSION").should include("1.3.0")
        bump("minor").should_not include("alpha")
        read("VERSION").should_not include("alpha")
      end

      it "major should drop prerelease" do
        bump("major").should include("2.0.0")
        read("VERSION").should include("2.0.0")
        bump("major").should_not include("alpha")
        read("VERSION").should_not include("alpha")
      end

      context "alpha" do
        it "should bump to beta" do
          bump("pre").should include("1.2.3-beta")
          read("VERSION").should include("1.2.3-beta")
        end
      end

      context "beta" do
        let(:version) { "1.2.3-beta" }
        it "should bump to rc" do
          bump("pre").should include("1.2.3-rc")
          read("VERSION").should include("1.2.3-rc")
        end
      end

      context "rc" do
        let(:version) { "1.2.3-rc" }
        it "should bump to final" do
          bump("pre").should include("1.2.3")
          read("VERSION").should include("1.2.3")
        end
      end

      context "final" do
        let(:version) { "1.2.3" }
        it "should bump to alpha" do
          bump("pre").should include("1.2.3-alpha")
          read("VERSION").should include("1.2.3-alpha")
        end
      end
    end
  end

  context "with a Gemfile" do
    before do
      write_gemspec('"1.0.0"')
      write "Gemfile", <<-RUBY
        source 'https://rubygems.org'
        # a gem not in the Gemfile used to run this test
        gem 'a1330ks_bmi', '~> 0.0.1'
        gemspec
      RUBY
      `git add Gemfile #{gemspec}`
      bundler_with_clean_env { run("bundle") }
      `git add Gemfile.lock`
    end

    it "bundle to keep version up to date and commit changed Gemfile.lock" do
      bump("patch")
      read("Gemfile.lock").should include "1.0.1"
      `git status`.should include "nothing to commit"
    end

    it "does not bundle with --no-bundle" do
      bump("patch --no-bundle")
      read(gemspec).should include "1.0.1"
      read("Gemfile.lock").should include "1.0.0"
      `git status --porcelain`.should_not include "Gemfile.lock"
    end

    it "fails when it cannot bundle" do
      File.write(gemspec, File.read(gemspec) + 'BLOB')
      bump("patch", fail: true).should include "Bundle error"
    end

    it "does not bundle when not in a library" do
      File.write('VERSION', '1.0.0')
      File.unlink gemspec
      bump("patch")
      read("Gemfile.lock").should include "1.0.0"
      `git status --porcelain`.should_not include "Gemfile.lock"
    end

    it "does not bundle or commit an untracked Gemfile.lock" do
      `git reset Gemfile.lock`
      bump("patch")
      read("Gemfile.lock").should include "1.0.0"
      `git status --porcelain`.should include "?? Gemfile.lock"
    end
  end

  context "with Changelog" do
    before do
      write_gemspec('"1.0.0"')
      write "CHANGELOG.md", <<-FILE.gsub(/^\s+/, "")
        ## Next
        - foo
        ## v1.0.0
        - bar
      FILE
      `git add CHANGELOG.md #{gemspec}`
    end

    it "updates changelog" do
      bump("patch --changelog")
      read("CHANGELOG.md").should include "## v1.0.1"
      `git status`.should include "nothing to commit"
    end

    it "complains when changelog is not found" do
      File.delete "CHANGELOG.md"
      bump("patch --changelog", fail: true)
    end

    it "can wait for editor" do
      with_env "EDITOR" => "echo edit" do
        bump("patch --edit-changelog").should include("edit CHANGELOG.md\n[master")
      end
    end

    context "Changelog without ## Next" do
      before do
        write_gemspec('"1.0.0"')
        write "CHANGELOG.md", <<-FILE.gsub(/^\s+/, "")
          ## v1.0.0
          - bar
        FILE
        `git add CHANGELOG.md #{gemspec}`
      end

      it "updates changelog" do
        bump("patch --changelog")
        read("CHANGELOG.md").should start_with "## v1.0.1\n## v1.0.0"
        `git status`.should include "nothing to commit"
      end
    end
  end

  context ".current" do
    it "returns the version as a string" do
      write_gemspec
      Bump::Bump.current.should == "4.2.3"
    end
  end

  context ".file" do
    it "returns the version file path as a string" do
      write_gemspec
      Bump::Bump.file.should == "fixture.gemspec"
    end
  end

  context ".parse_cli_options!" do
    it "returns the evaluated values of passed hash options" do
      Bump::Bump.parse_cli_options!(tag: 'nil')
                .should == {}

      Bump::Bump.parse_cli_options!(commit: 'true', bundle: 'false')
                .should == { commit: true, bundle: false }

      options = { tag: 'nil', commit: 'true', bundle: 'false' }
      expected_return = { commit: true, bundle: false }
      Bump::Bump.parse_cli_options!(options).should == expected_return
      options.should == expected_return
    end
  end

  context "VERSION in lib file" do
    let(:version_file) { "lib/foo.rb" }

    before do
      write_version_file
      write("lib/random_other_file.rb", "foo")
      write("lib/random/other/file.rb", "foo")
    end

    it "show current" do
      bump("current").should include("1.2.3")
      read(version_file).should include('  VERSION = "1.2.3"')
    end

    it "show next patch version" do
      bump("show-next patch").should include("1.2.4")
    end

    it "show file path" do
      bump("file").should include(version_file)
    end

    it "should bump VERSION" do
      bump("minor").should include("1.3.0")
      read(version_file).should include('  VERSION = "1.3.0"')
    end

    it "should set VERSION" do
      bump("set 1.3.0").should include("1.3.0")
      read(version_file).should include('  VERSION = "1.3.0"')
    end

    it "should bump Version" do
      write version_file, <<-RUBY.sub(" " * 8, "")
        module Foo
          Version = "1.2.3"
        end
      RUBY
      bump("minor").should include("1.3.0")
      read(version_file).should include('  Version = "1.3.0"')
    end

    it "should set Version" do
      write version_file, <<-RUBY.sub(" " * 8, "")
        module Foo
          Version = "1.2.3"
        end
      RUBY
      bump("set 1.3.0").should include("1.3.0")
      read(version_file).should include('  Version = "1.3.0"')
    end

    it "should bump if a gemspec exists and leave it alone" do
      write_gemspec "'1.'+'2.3'"
      bump("minor").should include("1.3.0")
      read(gemspec).should include("version = '1.'+'2.3'")
    end

    context "that is nested" do
      let(:version_file) { "lib/bar/baz/foo.rb" }

      it "show current" do
        bump("current").should include("1.2.3")
        read(version_file).should include('  VERSION = "1.2.3"')
      end

      it "show next patch version" do
        bump("show-next patch").should include("1.2.4")
        read(version_file).should include('  VERSION = "1.2.3"')
      end

      it "show file path" do
        bump("file").should include(version_file)
      end
    end
  end

  context "version in metadata.rb" do
    let(:version) { "1.2.3" }
    let(:version_file) { "metadata.rb" }

    before do
      write version_file, "foo :bar\nversion '#{version}'\nbar :baz\n"
    end

    it "should bump version" do
      bump("minor").should include("1.3.0")
      read(version_file).should include("1.3.0")
    end

    it "should set the version" do
      bump("set 1.3.0").should include("1.3.0")
      read(version_file).should include("1.3.0")
    end
  end

  context 'verify private class methods' do
    it 'raise exception when called' do
      -> { Bump::Bump.bump('foo', '1.2.3', '1.2.4', {}) }.should raise_error NoMethodError
    end

    it 'has private methods' do
      Bump::Bump.private_methods(false).size.should > Object.private_methods(false).size
    end
  end

  context '.bump_changelog' do
    it "bumps" do
      Tempfile.create('test-bump_changelog') do |f|
        f.write <<-TEXT.gsub(/^\s+/, "")
          ## Next
          - foo
          ## v1.2.3
          - bar
        TEXT
        f.close
        Bump::Bump.send(:bump_changelog, f.path, '1.3.0').should eq nil
        File.read(f.path).should == <<-TEXT.gsub(/^\s+/, "")
          ## Next
          ## v1.3.0
          - foo
          ## v1.2.3
          - bar
        TEXT
      end
    end

    it "adds date" do
      Tempfile.create('test-bump_changelog') do |f|
        f.write <<-TEXT.gsub(/^\s+/, "")
          ## Next
          - foo
          ## Version 1.2.3 released on 2018-10-11
          - bar
        TEXT
        f.close
        Bump::Bump.send(:bump_changelog, f.path, '1.3.0').should eq nil
        File.read(f.path).should == <<-TEXT.gsub(/^\s+/, "")
          ## Next
          ## Version 1.3.0 released on #{Time.now.strftime('%Y-%m-%d')}
          - foo
          ## Version 1.2.3 released on 2018-10-11
          - bar
        TEXT
      end
    end

    it "shows error when it cannot find a line" do
      Tempfile.create('test-bump_changelog') do |f|
        f.write <<-TEXT.gsub(/^\s+/, "")
          Wut ?
        TEXT
        f.close
        Bump::Bump.send(:bump_changelog, f.path, '1.3.0').should == "Unable to find previous version in CHANGELOG.md"
      end
    end
  end

  private

  def bump(command = "", options = {})
    cmdline = "#{File.expand_path('../bin/bump', __dir__)} #{command}"
    run cmdline, options
  end

  def write_gemspec(version = '"4.2.3"')
    write gemspec, <<-RUBY.sub(" " * 6, "")
      Gem::Specification.new do |s|
        s.author  = 'joe'
        s.name    = 'fixture'
        s.version = #{version}
        s.summary = 'Fixture gem'
        s.add_runtime_dependency 'parallel'
      end
    RUBY
  end

  def write_version_file(version = '"1.2.3"')
    write version_file, <<-RUBY.sub(" " * 6, "")
      module Foo
        VERSION = #{version}
      end
    RUBY
  end

  def with_file(file, content)
    File.write(file, content)
    yield
  ensure
    File.unlink file
  end

  def bundler_with_clean_env(&block)
    if Bundler.respond_to?(:with_unbundled_env)
      Bundler.with_unbundled_env(&block)
    else
      Bundler.with_clean_env(&block)
    end
  end
end

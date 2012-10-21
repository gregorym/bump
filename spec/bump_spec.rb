require File.dirname(__FILE__) + "/../lib/bump.rb"

describe Bump do
  let(:gemspec){ "fixture.gemspec" }
  let(:version_rb_file){ "lib/foo/version.rb" }

  around do |example|
    run "rm -rf fixture && mkdir fixture"
    Dir.chdir "fixture" do
      `git init && git commit --allow-empty -am 'initial'` # so we never accidentally do commit to the current repo
      example.call
    end
    run "rm -rf fixture"
  end

  it "should fail if it cannot find anything to bump" do
    bump("current", :fail => true).should include "Unable to find"
  end

  it "should fail without command" do
    write_gemspec
    bump("", :fail => true).should include "Usage instructions: bump --help"
  end

  it "should fail with invalid options" do
    write_gemspec
    bump("xxx", :fail => true).should include "Invalid option"
  end

  it "should fail with multiple gemspecs" do
    write_gemspec
    write("xxxx.gemspec", "Gem::Specification.new{}")
    bump("current", :fail => true).should include "More than one gemspec file"
  end

  it "should fail if version is weird" do
    write_gemspec('"1."+"3.4"')
    bump("current", :fail => true).should include "Unable to find a file with the gem version"
  end

  it "should show help" do
    bump("--help").should include("bump current")
  end

  context "git" do
    it "should commit the new version" do
      write_gemspec
      bump("patch")
      `git log -1 --pretty=format:'%s'`.should == "v4.2.4"
      `git status`.should include "nothing to commit"
    end

    it "should not commit if --no-commit flag was given" do
      write_gemspec
      bump("patch --no-commit")
      `git log -1 --pretty=format:'%s'`.should == "initial"
      `git status`.should_not include "nothing to commit"
    end
  end

  context ".version in gemspec" do
    before do
      write_gemspec
    end

    it "should find current version" do
      bump("current").should include("4.2.3")
      read(gemspec).should include('s.version = "4.2.3"')
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
  end

  context "VERSION in version.rb" do
    before do
      write_version_rb
    end

    it "show current" do
      bump("current").should include("1.2.3")
      read(version_rb_file).should include('  VERSION = "1.2.3"')
    end

    it "should bump VERSION" do
      bump("minor").should include("1.3.0")
      read(version_rb_file).should include('  VERSION = "1.3.0"')
    end

    it "should bump Version" do
      write version_rb_file, <<-RUBY.sub(" "*8, "")
        module Foo
          Version = "1.2.3"
        end
      RUBY
      bump("minor").should include("1.3.0")
      read(version_rb_file).should include('  Version = "1.3.0"')
    end

    it "should bump if a gemspec exists and leave it alone" do
      write_gemspec "'1.'+'2.3'"
      bump("minor").should include("1.3.0")
      read(gemspec).should include("version = '1.'+'2.3'")
    end
  end

  context "version in VERSION" do
    let(:version) { "1.2.3" }

    before do
      write "VERSION", "#{version}\n"
    end

    it "show current" do
      bump("current").should include("#{version}")
      read("VERSION").should include("#{version}")
    end

    it "should bump version" do
      bump("minor").should include("1.3.0")
      read("VERSION").should include("1.3.0")
    end

    it "should bump if a gemspec & version.rb exists and leave it alone" do
      write_gemspec "File.read('VERSION')"
      write_version_rb "File.read('VERSION')"
      bump("minor").should include("1.3.0")
      read("VERSION").should include("1.3.0")
      read(version_rb_file).should include("VERSION = File.read('VERSION')")
      read(gemspec).should include("version = File.read('VERSION')")
    end
  end

  private

  def write(file, content)
    folder = File.dirname(file)
    run "mkdir -p #{folder}" unless File.exist?(folder)
    File.open(file, 'w'){|f| f.write content }
  end

  def read(file)
    File.read(file)
  end

  def run(cmd, options={})
    result = `#{cmd} 2>&1`
    raise "FAILED #{cmd} --> #{result}" if $?.success? != !options[:fail]
    result
  end

  def bump(command="", options={})
    run "#{File.expand_path("../../bin/bump", __FILE__)} #{command}", options
  end

  def write_gemspec(version = '"4.2.3"')
    write gemspec, <<-RUBY.sub(" "*6, "")
      Gem::Specification.new do |s|
        s.version = #{version}
      end
    RUBY
  end

  def write_version_rb(version = '"1.2.3"')
    write version_rb_file, <<-RUBY.sub(" "*6, "")
      module Foo
        VERSION = #{version}
      end
    RUBY
  end
end

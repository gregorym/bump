require File.dirname(__FILE__) + "/../lib/bump.rb"

describe Bump do
  let(:gemspec){ "fixture.gemspec" }

  around do |example|
    run "rm -rf fixture && mkdir fixture"
    Dir.chdir "fixture" do
      example.call
    end
    run "rm -rf fixture"
  end

  it "should fail if it cannot find anything to bump" do
    bump("current", :fail => true).should include "Unable to find"
  end

  it "should fail without command" do
    write_gemspec
    bump("", :fail => true).should include "Invalid option"
  end

  it "should fail with multiple gemspecs" do
    write_gemspec
    write("xxxx.gemspec", "xxx")
    bump("current", :fail => true).should include "More than one gemspec file"
  end

  it "should fail if version is weird" do
    write_gemspec('"a.b.c"')
    bump("current", :fail => true).should include "Unable to find your gem version"
  end

  context ".version in gemspec" do
    before do
      write_gemspec
    end

    it "should find current version" do
      bump("current").should include("4.2.3")
      read(gemspec).should include('s.version = "4.2.3"')
    end

    it "should bump tiny" do
      bump("tiny").should include("4.2.4")
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
      bump("tiny").should include("4.2.4")
      bump("tiny").should include("4.2.5")
      bump("tiny").should include("4.2.6")
      bump("tiny").should include("4.2.7")
      bump("tiny").should include("4.2.8")
      bump("tiny").should include("4.2.9")
      bump("tiny").should include("4.2.10")
      bump("tiny").should include("4.2.11")
      read(gemspec).should include('s.version = "4.2.11"')
    end
  end

  context "VERSION in version.rb" do
    before do
      write "lib/foo/version.rb", <<-RUBY.sub(" "*8, "")
        module Foo
          VERSION = "1.2.3"
        end
      RUBY
    end

    it "show current" do
      bump("current").should include("1.2.3")
      read("lib/foo/version.rb").should include('  VERSION = "1.2.3"')
    end

    it "should bump VERSION" do
      bump("minor").should include("1.3.0")
      read("lib/foo/version.rb").should include('  VERSION = "1.3.0"')
    end

    it "should bump Version" do
      write "lib/foo/version.rb", <<-RUBY.sub(" "*8, "")
        module Foo
          Version = "1.2.3"
        end
      RUBY
      bump("minor").should include("1.3.0")
      read("lib/foo/version.rb").should include('  Version = "1.3.0"')
    end

    it "should bump if a gemspec exists and leave it alone" do
      write_gemspec "Foo::VERSION"
      bump("minor").should include("1.3.0")
      read("lib/foo/version.rb").should include('  VERSION = "1.3.0"')
      read(gemspec).should include('version = Foo::VERSION')
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
end

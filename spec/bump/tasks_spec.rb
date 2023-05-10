# frozen_string_literal: true

require "spec_helper"

describe "rake bump" do
  inside_of_folder("spec/fixture")

  before do
    write "VERSION", "1.2.3\n"
    rakefile_require = "require File.expand_path('../../../lib/bump/tasks', __FILE__)"
    write "Rakefile", rakefile_require
    write "Rakefile.with_defaults", "#{rakefile_require}\nBump.tag_by_default = true"
    raise unless system("git add VERSION")
  end

  it "bumps a version" do
    output = run "rake bump:minor"
    output.should include("1.3.0")
    read("VERSION").should == "1.3.0\n"
    `git log -1 --pretty=format:'%s'`.should == "v1.3.0"
  end

  it "shows next patch version" do
    output = run "rake bump:show-next INCREMENT=patch"
    output.should include("1.2.4")
  end

  it "bumps a version and can optionally tag it with a prefix defaulting to 'v'" do
    run "rake bump:patch TAG=true"
    `git tag`.split("\n").last.should == "v1.2.4"
  end

  it "bumps a version and can optionally tag it without a prefix if tag_prefix is set to false" do
    run 'rake bump:patch TAG=true TAG_PREFIX=""'
    `git tag`.split("\n").last.should == "1.2.4"
  end

  it "bumps a version and can optionally tag it with the given prefix if tag_prefix is set to a value" do
    run "rake bump:patch TAG=true TAG_PREFIX=v-"
    `git tag`.split("\n").last.should == "v-1.2.4"
  end

  it "fails with rake arguments" do
    run "rake bump:patch[true]", fail: true
  end

  it "honors the tag setting in Bump::Bump.defaults" do
    run "rake -f Rakefile.with_defaults bump:patch"
    `git tag`.split("\n").last.should == "v1.2.4"
  end

  it "does not tag by default" do
    run "rake bump:patch"
    `git tag`.split("\n").last.should be_nil
  end

  it "sets a version" do
    output = run "VERSION=1.3.0 rake bump:set"
    output.should include("1.3.0")
    read("VERSION").should == "1.3.0\n"
    `git log -1 --pretty=format:'%s'`.should == "v1.3.0"
  end

  it "appends commit message" do
    output = run "COMMIT_MESSAGE='release' rake bump:minor"
    output.should include("1.3.0")
    read("VERSION").should == "1.3.0\n"
    `git log -1 --pretty=format:'%s'`.should == "v1.3.0 release"
  end

  it "appends custom commit message" do
    output = run "CUSTOM_COMMIT_MESSAGE='chore: {TAG} release' rake bump:minor"
    output.should include("1.3.0")
    read("VERSION").should == "1.3.0\n"
    `git log -1 --pretty=format:'%s'`.should == "chore: v1.3.0 release"
  end

  it "fails when it cannot bump" do
    write "VERSION", "AAA"
    run "rake bump:minor", fail: true
  end

  it "shows the current version" do
    result = run "rake bump:current"
    result.should include("1.2.3")
  end

  it "shows the version file path" do
    result = run "rake bump:file"
    result.should include("VERSION")
  end
end

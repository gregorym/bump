require "spec_helper"

describe "rake bump" do
  inside_of_folder("spec/fixture")

  before do
    write "VERSION", "1.2.3\n"
    write "Rakefile", "require File.expand_path('../../../lib/bump/tasks', __FILE__)"
    raise unless system("git add VERSION")
  end

  it "bumps a version" do
    output = run "rake bump:minor"
    output.should include("1.3.0")
    read("VERSION").should == "1.3.0\n"
    `git log -1 --pretty=format:'%s'`.should == "v1.3.0"
  end

  it "sets a version" do
    output = run "VERSION=1.3.0 rake bump:set"
    output.should include("1.3.0")
    read("VERSION").should == "1.3.0\n"
    `git log -1 --pretty=format:'%s'`.should == "v1.3.0"
  end

  it "fails when it cannot bump" do
    write "VERSION", "AAA"
    run "rake bump:minor", :fail => true
  end

  it "shows the version" do
    result = run "rake bump:current"
    result.should include("1.2.3")
  end
end

require File.dirname(__FILE__) + "/../lib/bump.rb"

describe Bump do
  
  before(:each) do
    gemspec = %(Gem::Specification.new do |s|
      s.version = "1.0.0"
    end)
    path = File.expand_path("fixture.gemspec","fixture/") 
    File.open(path, 'w') {|f| f.write(gemspec) }
  end

  after(:each) do
    path = File.expand_path("fixture.gemspec","fixture/") 
    File.open(path, 'w') {|f| f.write("") }
  end

  it "should find current version" do
    bump = Bump::Bump.new("current")
    bump.gemspec_path = File.dirname(__FILE__) + "/fixture/fixture.gemspec"
    output = bump.run
    output.include?("1.0.0").should be_true
  end

  it "should bump a tiny version" do
    bump = Bump::Bump.new("tiny")
    bump.gemspec_path = File.dirname(__FILE__) + "/fixture/fixture.gemspec"
    output = bump.run
    output.include?("1.0.1").should be_true
  end
  
  it "should bump a minor version" do
    bump = Bump::Bump.new("minor")
    bump.gemspec_path = File.dirname(__FILE__) + "/fixture/fixture.gemspec"
    output = bump.run
    output.include?("1.1.0").should be_true
  end
  
  it "should bump a major version" do
    bump = Bump::Bump.new("major")
    bump.gemspec_path = File.dirname(__FILE__) + "/fixture/fixture.gemspec"
    output = bump.run
    output.include?("2.0.0").should be_true
  end

end
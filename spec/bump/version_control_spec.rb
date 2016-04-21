require "spec_helper"

describe Bump::VersionControl do

  context 'git' do
    inside_of_folder("spec/fixture", :git)

    context 'recognize repository' do
      it 'as git' do
        Bump::VersionControl.git?.should == true
      end

      it 'not as mercurial' do
        Bump::VersionControl.mercurial?.should == false
      end
    end

    context 'commit' do
      it "should commit the new version" do
        write 'tmpfile', 'test'
        `git add tmpfile`
        write 'tmpfile', 'test2'

        Bump::VersionControl.commit('4.2.4', 'tmpfile', {})

        `git log -1 --pretty=format:'%s'`.should == "v4.2.4"
        `git status`.should include "nothing to commit"
      end

      it "should not add untracked file" do
        write 'tmpfile', 'test'

        Bump::VersionControl.commit('4.2.4', 'tmpfile', {})

        `git log -1 --pretty=format:'%s'`.should == "initial"
        `git status`.should include "Untracked files:"
      end

      it "should tag if tag option given" do
        write 'tmpfile', 'test'
        `git add tmpfile`

        Bump::VersionControl.commit('4.2.4', 'tmpfile', {tag: true})

        `git tag -l`.should include 'v4.2.4'
      end

      it "should not tag no tag option given" do
        write 'tmpfile', 'test'
        `git add tmpfile`

        Bump::VersionControl.commit('4.2.4', 'tmpfile', {})

        `git tag -l`.should == ''
      end
    end

    it 'can report if file is tracked' do
      write 'tmpfile1', 'test'
      write 'tmpfile2', 'test'
      `git add tmpfile1`

      Bump::VersionControl.under_version_control?('tmpfile1').should == true
      Bump::VersionControl.under_version_control?('tmpfile2').should == false
    end

    context 'Gemfile.lock' do
      it 'should commit if bundle option is given' do
        write 'Gemfile.lock', 'test1'
        write 'tmpfile', 'test1'
        `git add Gemfile.lock tmpfile`
        `git commit -m "gemfile tracked"`

        write 'Gemfile.lock', 'test2'
        write 'tmpfile', 'test2'

        Bump::VersionControl.commit('4.2.4', 'tmpfile', {bundle: true})
        `git status`.should_not include "Gemfile.lock"
      end

      it 'should not commit if bundle option is missing' do
        write 'Gemfile.lock', 'test1'
        write 'tmpfile', 'test1'
        `git add Gemfile.lock tmpfile`
        `git commit -m "gemfile tracked"`

        write 'Gemfile.lock', 'test2'
        write 'tmpfile', 'test2'

        Bump::VersionControl.commit('4.2.4', 'tmpfile', {bundle: false})
        `git status`.should include "Gemfile.lock"
      end
    end

  end

  context 'hg' do
    inside_of_folder("spec/fixture", :mercurial)

    context 'recognize repository' do
      it 'as mercurial' do
        Bump::VersionControl.mercurial?.should == true
      end

      it 'not as git' do
        Bump::VersionControl.git?.should == false
      end
    end

    context 'commit' do
      it "should commit the new version" do
        write 'tmpfile', 'test'
        `hg add tmpfile`
        write 'tmpfile', 'test2'

        Bump::VersionControl.commit('4.2.4', 'tmpfile', {})

        `hg log --limit 1 --template "{desc}"`.should == "v4.2.4"
        `hg status`.should == ''
      end

      it "should not add untracked file" do
        write 'tmpfile', 'test'

        Bump::VersionControl.commit('4.2.4', 'tmpfile', {})

        `hg log --limit 1 --template "{desc}"`.should == ""
        `hg status`.should_not == ''
      end

      it "should tag if tag option given" do
        write 'tmpfile', 'test'
        `hg add tmpfile`

        Bump::VersionControl.commit('4.2.4', 'tmpfile', {tag: true})

        `hg tags`.should include 'v4.2.4'
      end

      it "should not tag no tag option given" do
        write 'tmpfile', 'test'
        `hg add tmpfile`

        Bump::VersionControl.commit('4.2.4', 'tmpfile', {})

        `hg tags`.should_not include 'v4.2.4'
      end

      it 'can report if file is tracked' do
        write 'tmpfile1', 'test'
        `hg commit -Am "track file"`
        write 'tmpfile2', 'test'

        Bump::VersionControl.under_version_control?('tmpfile1').should == true
        Bump::VersionControl.under_version_control?('tmpfile2').should == false
      end
    end

    context 'Gemfile.lock' do
      it 'should commit if bundle option is given' do
        write 'Gemfile.lock', 'test1'
        write 'tmpfile', 'test1'
        `hg add Gemfile.lock tmpfile`
        `hg commit -m "gemfile tracked"`
        write 'Gemfile.lock', 'test2'
        write 'tmpfile', 'test2'

        Bump::VersionControl.commit('4.2.4', 'tmpfile', {bundle: true})
        `hg status`.should_not include "Gemfile.lock"
      end

      it 'should not commit if bundle option is missing' do
        write 'Gemfile.lock', 'test1'
        write 'tmpfile', 'test1'
        `hg add Gemfile.lock tmpfile`
        `hg commit -m "gemfile tracked"`
        write 'Gemfile.lock', 'test2'
        write 'tmpfile', 'test2'

        Bump::VersionControl.commit('4.2.4', 'tmpfile', {bundle: false})
        `hg status`.should include "Gemfile.lock"
      end
    end
  end

end

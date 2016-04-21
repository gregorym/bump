module Bump
  class VersionControlNotFoundError < StandardError; end

  class VersionControl
    def self.git?
      File.directory?(".git")
    end

    def self.mercurial?
      File.directory?(".hg")
    end

    def self.commit(version, file, options)
      case
      when git?
        system("git add --update Gemfile.lock") if options[:bundle]
        system("git add --update #{file} && git commit -m '#{commit_message(version, options)}'")
        system("git tag -a -m 'Bump to v#{version}' v#{version}") if options[:tag]
      when mercurial?
        system("hg add Gemfile.lock") if options[:bundle]
        system("hg add #{file} && hg commit -m '#{commit_message(version, options)}'")
        system("hg tag -m 'Bump to v#{version}' v#{version}") if options[:tag]
      else
        raise VersionControlNotFoundError
      end
    end

    def self.commit_message(version, options)
      (options[:commit_message]) ? "v#{version} #{options[:commit_message]}" : "v#{version}"
    end

    def self.under_version_control?(file)
      case
      when git?
        @all_files ||= `git ls-files`.split(/\r?\n/)
      when mercurial?
        @all_files ||= `hg manifest`.split(/\r?\n/)
      else
        raise VersionControlNotFoundError
      end
      @all_files.include?(file) if @all_files
    end
  end
end
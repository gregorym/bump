module Bump
  class VersionControlNotFoundError < StandardError; end

  class VersionControl
    def self.commit(version, file, options)
      case
      when git?
        `git add --update Gemfile.lock` if options[:bundle]
        `git add --update #{file} && git commit -m '#{commit_message(version, options)}'`
        `git tag -a -m 'Bump to v#{version}' v#{version}` if options[:tag]
      when mercurial?
        files = [file]
        files << 'Gemfile.lock' if options[:bundle]
        include_files = files.reduce([]) { |a, n| a << '-I' << n }.join(' ')
        `hg commit #{include_files} -m '#{commit_message(version, options)}'`
        `hg tag -m 'Bump to v#{version}' v#{version}` if options[:tag]
      else
        raise VersionControlNotFoundError
      end
    end

    def self.under_version_control?(file)
      @all_files ||= case
      when git?
        `git ls-files`.split(/\r?\n/)
      when mercurial?
        `hg manifest`.split(/\r?\n/)
      else
        raise VersionControlNotFoundError
      end
      @all_files.include?(file) if @all_files
    end

    def self.git?
      File.directory?(".git")
    end
    private_class_method :git?

    def self.mercurial?
      File.directory?(".hg")
    end
    private_class_method :mercurial?

    def self.commit_message(version, options)
      (options[:commit_message]) ? "v#{version} #{options[:commit_message]}" : "v#{version}"
    end
    private_class_method :commit_message

  end
end
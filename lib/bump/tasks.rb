require "bump"

namespace :bump do
  run_bump = lambda do |bump, options|
    output, status = Bump::Bump.run(bump, options)
    puts output
    abort unless status == 0
  end

  (Bump::Bump::BUMPS + ["current"]).each do |bump|
    if bump == "current"
      desc "Show current gem version"
    else
      desc "Bump #{bump} part of gem version"
    end

    task bump, :tag do |_task, args|
      raise RakeArgumentsDeprecatedError,
        "rake arguments are deprecated, use TAG=false to disable tagging" if args.tag
      options = {
        tag: ENV['TAG'],
        commit: ENV['COMMIT'],
        bundle: ENV['BUNDLE']
      }
      run_bump.call(bump, options)
    end
  end

  desc "Sets the version number using the VERSION environment variable"
  task :set do
    run_bump.call("set", :version => ENV['VERSION'])
  end
end

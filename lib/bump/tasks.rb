require "bump"

namespace :bump do
  (Bump::Bump::BUMPS + ["current"]).each do |bump|
    if bump == "current"
      desc "Show current gem version"
    else
      desc "Bump #{bump} part of gem version"
    end

    task bump do
      output, status = Bump::Bump.run(bump)
      puts output
      abort unless status == 0
    end
  end
end

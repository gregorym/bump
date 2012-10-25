require "bump"

namespace :bump do
  (Bump::Bump::BUMPS + ["current"]).each do |bump|
    task bump do
      output, status = Bump::Bump.run(bump)
      puts output
      abort unless status == 0
    end
  end
end

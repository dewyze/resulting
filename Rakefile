require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)

desc "Rubocop changed"
task :rubocop_changed do
  puts "Running rubocop on changed files..."
  system("bundle exec rubocop --force-exclusion -a $(git diff HEAD --name-only --diff-filter=MA & git ls-files --other --exclude-standard | sort | uniq)")
end

task default: %w[spec rubocop_changed]

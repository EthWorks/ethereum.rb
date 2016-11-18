require "bundler/gem_tasks"
require "rspec/core/rake_task"

import "./lib/tasks/ethereum_test.rake"
import "./lib/tasks/ethereum_node.rake"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

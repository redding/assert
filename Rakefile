include Rake::DSL

require 'bundler'
Bundler::GemHelper.install_tasks

require 'test_belt/rake_tasks'
TestBelt::RakeTasks.for :test
TestBelt::RakeTasks.for :examples

task :default => :build

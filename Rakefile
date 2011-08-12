include Rake::DSL

require 'bundler'
Bundler::GemHelper.install_tasks

require 'lib/assert/rake_tasks'
Assert::RakeTasks.for :test

# Kelly, this can be removed if you don't need it, wanted to leave it here in case you wanted it
# for documentation reasons
#require 'rake/testtask'
#Rake::TestTask.new do |t|
#  t.libs << "."
#  t.test_files = FileList['test/**/*_test.rb']
#  t.verbose = true
#end


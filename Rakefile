include Rake::DSL

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << "."
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

Rake::TestTask.new do |t|
  t.name = "test:assertions"
  t.libs << "."
  t.test_files = 'test/assertions_test.rb'
  t.verbose = true
end

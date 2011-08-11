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
  t.name = "test:context"
  t.libs << "."
  t.test_files = FileList['test/context_test.rb', 'test/context/**/*_test.rb']
  t.verbose = true
end

Rake::TestTask.new do |t|
  t.name = "test:assertions"
  t.libs << "."
  t.test_files = FileList['test/assertions_test.rb', 'test/assertions/**/*_test.rb']
  t.verbose = true
end

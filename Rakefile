require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "lib/rubefunge"
  t.test_files = FileList["test/lib/rubefunge/*_test.rb"]
  t.verbose = true
end

task :default do
  puts %x{rake --tasks}
end

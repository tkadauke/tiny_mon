# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

TinyMon::Application.load_tasks

begin
  require 'resque/tasks'
rescue LoadError
end

begin
  require 'i18n_tools/tasks'
rescue LoadError
end

namespace :test do
  desc 'Measure test coverage'
  task :coverage do
    output_dir = "test/coverage"
    rm_f "#{output_dir}/*"
    rm_f "#{output_dir}/coverage.data"
    mkdir_p output_dir
    rcov = "rcov -o #{output_dir} --rails --aggregate #{output_dir}/coverage.data --text-summary --exclude=\"gems/*,rubygems/*,rcov*,modules/*\" -Ilib"

    test_files = Dir.glob('test/unit/**/*_test.rb')
    sh %{#{rcov} #{test_files.join(' ')}} unless test_files.empty?

    test_files = Dir.glob('test/functional/**/*_test.rb')
    sh %{#{rcov} --html #{test_files.join(' ')} -v} unless test_files.empty?
  end
end

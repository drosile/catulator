task default: :test

desc "start app"
task :start do
  exec 'shotgun -r pry -o 0.0.0.0'
end

desc "start console"
task :console do
  exec 'pry -r./app'
end

desc "run all tests"
task test: ["test:api"]

namespace :test do
  task :api do
    run "test/api/**/*.rb"
  end
end

namespace :db do
  desc "load env"
  task :environment do
    require 'dotenv'
    Dotenv.load

    require_relative 'config/db'
    Sequel.extension :migration
  end

  desc "version"
  task :version => [:environment] do
    version = if DB.tables.include?(:schema_info)
      DB[:schema_info].first[:version]
    end || 0
    puts "Schema Version: #{version}"
  end

  desc "perform migrations"
  task :migrate => [:environment] do
    Sequel::Migrator.run(DB, 'migrations')
    Rake::Task['db:version'].execute
  end
end

def run(dir)
  Dir[dir].each { |file| load file }
end


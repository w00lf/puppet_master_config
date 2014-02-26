root_dir = File.join(File.dirname(__FILE__), '..')
require File.join(root_dir, 'db_connection.rb')

namespace :db do
  desc "Migrate the database"
  task :migrate do
    ActiveRecord::Migrator.migrate(File.join(root_dir, 'db', 'migrate'), ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end
end
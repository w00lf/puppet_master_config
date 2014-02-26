require 'rubygems'
require 'yaml'
require 'logger'
require 'active_record'

dbconfig = YAML::load(File.open(File.join(File.dirname(__FILE__), 'db', 'database.yml')))
ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.establish_connection(dbconfig)
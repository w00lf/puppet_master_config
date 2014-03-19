require 'rubygems'
require 'murder'
set :user, "mik"
set :remote_murder_path, '/usr/local/lib/ruby/gems/1.9/gems/murder-0.1.2/dist' # or some other directory

role :peer, 'puppet-master.ddc-media.local', 'puppet-agent.ddc-media.local'
role :seeder, 'puppet-master.ddc-media.local'
role :tracker, 'puppet-master.ddc-media.local'

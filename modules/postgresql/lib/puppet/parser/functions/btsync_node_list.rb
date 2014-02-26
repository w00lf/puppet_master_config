module Puppet::Parser::Functions
  newfunction(:btsync_node_list, :type => :rvalue) do |args|
    require File.join('/usr/local/etc/puppet/ruby/lib', 'db_connection.rb')
    require File.join('/usr/local/etc/puppet/ruby/lib', 'node.rb')
    Node.all.map {|nod| "\"#{nod.domain}:#{nod.port}\"" }
  end
end
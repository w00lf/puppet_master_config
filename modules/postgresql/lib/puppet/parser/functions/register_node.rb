module Puppet::Parser::Functions
  newfunction(:register_node) do |args|
    require File.join('/usr/local/etc/puppet/ruby/lib', 'db_connection.rb')
    require File.join('/usr/local/etc/puppet/ruby/lib', 'node.rb')
    domain = args[0]
    ip = args[1]
    port = args[2] 
    Node.find_or_create_by_domain(domain: domain, ip: ip, port: port)
  end
end
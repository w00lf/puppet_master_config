class node_register {
  # TODO change method, remove port
  register_node($::fqdn, $::ipaddress, 44444)

  # $domain_name = $::fqdn

  # $btsync_dirs = [ "/home/taraskin/btsync/", "/home/mik/taraskin/shared"]
  # file { $btsync_dirs:
  #       ensure => "directory",
  #       owner  => "root",
  #       group  => "wheel",
  # }

  # file {'btsync.conf':
  #   ensure  => present,
  #   content => template('btsync.conf.erb'),
  #   path => '/home/taraskin/btsync/development.conf',
  #   require => File[$btsync_dirs]
  # }
}
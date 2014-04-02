class btsync($deploy_path, $shared_dir){
  $domain_name = $::fqdn

  $btsync_dir = "${deploy_path}/btsync/"
  $btsync_conf = "${btsync_dir}development.conf"
  $storage_path = "${btsync_dir}/.sync"
  exec{'/etc/rc.d/ntpdate onestart':
    logoutput => true,
  }->
  file { [$btsync_dir, $storage_path]:
    ensure => "directory",
    owner  => "mik",
    group  => "wheel",
  }->
  file {$btsync_conf:
    ensure  => present,
    content => template('btsync.conf.erb'),
  }->
  file {'btsync_freebsd_i386.tar.gz':
    ensure  => present,
    path => '/tmp/btsync_freebsd_i386.tar.gz',
    source => "puppet:///files/btsync/btsync_freebsd_i386.tar.gz"
  }->
  exec {'extract btsync exec':
    logoutput => true,
    command => "tar -xzf /tmp/btsync_freebsd_i386.tar.gz -C ${btsync_dir}"
  }->
  exec{"cd ${btsync_dir} && ./btsync --config ${btsync_conf}":
    logoutput => true
  }
}
 
class murder_setup($deploy_path = '/usr/local/www') {
  $murder_dist = 'murder.tgz'
  
  file{"${deploy_path}/shared/":
    owner  => "mik",
    ensure => directory,
    mode   => 750,          
  }->
  file { 'murder_dists':
    path => "/tmp/${murder_dist}",
    ensure => "present",
    mode   => 750,
    source => "puppet:///files/${murder_dist}"
  }->
  exec{"unpack murder dist files":
    command => "tar -xvzf /tmp/${murder_dist} -C ${deploy_path}/shared/",
  }


}
class mcollective_setup {
  $activemq_mcollective_password = 'changeme'
  $activemq_server = 'puppet-master.ddc-media.local'
  $mcollective_root = '/usr/local/etc/mcollective'

  package {'sysutils/mcollective':
    ensure   => installed,
    provider => 'freebsd'
  }->
  file{"${mcollective_root}/server.cfg":
    ensure => "present",
    content => template('server.cfg.erb')
  }->
  file{"${mcollective_root}/facts.yaml":
    owner    => root,
    group    => wheel,
    mode     => 400,
    loglevel => debug, # reduce noise in Puppet reports
    content  => inline_template("<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime_seconds|timestamp|free)/ }.to_yaml %>"), # exclude rapidly changing facts
  }->
  service {'mcollectived':
    ensure => "running",
  }
}
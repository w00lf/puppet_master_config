class sudoers {
	    file { "/usr/local/etc/sudoers":
		ensure  => file,
		owner   => root,
		group   => wheel,
		mode    => 440,
		source  => "puppet:///files/sudoers",
	 
	    }
	 
	}
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
class packages {
	$majorversion = regsubst($kernelversion, '^([0-9]+)\.([0-9]+)$', '\1')
	$scheme = 'http'
 	$host   = 'ftp.freebsd.org'
 	$urlpath = "/pub/FreeBSD/ports/${hardwareisa}/packages-${kernelversion}-release/"
	package { [ 'ftp/curl',
	      'editors/vim-lite',
	      'shells/bash',
	      'devel/git',
	      'security/ca_root_nss', # Need for master for module install wia ss
	      'graphics/ImageMagick',
	      'databases/redis',
	      'sysutils/mcollective',
	      'www/nginx',
              'archivers/rubygem-bzip2'
		 ]:
	      ensure   => installed,
	      provider => 'freebsd',	
	      source => "${scheme}://${host}/${urlpath}"
	}->
	service {['redis',
		'nginx',
		'mcollectived']:
		ensure => "running",
	}

	class { 'postgresql::globals':
                user => 'pgsql',
                group => 'pgsql',
        }->
        class { 'postgresql::server':
        }
  postgresql::server::role { 'orfograph':
  	password_hash => postgresql_password('orfograph', 'orfograph'),
	}->
	postgresql::server::db { 'orfograph':
	  user     => 'orfograph',
	  password => postgresql_password('orfograph', 'orfograph'),
	}->
	# postgresql::server::database_grant { 'orfograph':
	#   privilege => 'ALL',
	#   db        => 'orfograph',
	#   role      => 'orfograph',
	# }
  # TODO pick gems versions!
	package { ['bundler', 'unicorn', 'murder', 'capistrano']:
	   ensure   => 'installed',
	   provider => 'gem',
	}
}

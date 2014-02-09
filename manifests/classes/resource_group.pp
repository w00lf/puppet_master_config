class sudoers {
	    file { "/usr/local/etc/sudoers":
		ensure  => file,
		owner   => root,
		group   => wheel,
		mode    => 440,
		source  => "puppet:///files/sudoers",
	 
	    }
	 
	}
class packages {
	package { [ 'ftp/curl',
	      'editors/vim-lite',
	      'devel/git',
	      'security/ca_root_nss', # Need for master for module install wia ss
				'net/rsync',
	      #'portaudit',
	      #'portmaster',
	      #'tmux',
	      #'augeas'
		 ]:
	      ensure   => installed,
	      provider => freebsd,
	      source => "http://ftp.freebsd.org/pub/FreeBSD/ports/amd64/packages-9-stable/"
	}
	class { 'postgresql::globals':
                user => 'pgsql',
                group => 'pgsql',
        }->
        class { 'postgresql::server':
        }
	#package { 'sinatra':
	#    ensure   => 'installed',
	#    provider => 'gem',
	#}
}

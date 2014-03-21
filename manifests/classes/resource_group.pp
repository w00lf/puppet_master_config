class packages {
	# $majorversion = regsubst($kernelversion, '^([0-9]+)\.([0-9]+)$', '\1')
	# $scheme = 'http'
 # 	$host   = 'ftp.freebsd.org'
 # 	$urlpath = "/pub/FreeBSD/ports/${hardwareisa}/packages-${kernelversion}-release/"
	
	# package { [ 'ftp/curl',
	#       'editors/vim-lite',
	#       'shells/bash',
	#       'devel/git',
	#       'security/ca_root_nss', # Need for master for module install wia ss
	#       #'graphics/ImageMagick',
	#       'databases/redis',
 #        'archivers/rubygem-bzip2'
	# 	 ]:
	#       ensure   => installed,
	#       provider => 'freebsd',	
	#       # source => "${scheme}://${host}/${urlpath}"
	# }->
	# service {'redis':
	# 	ensure => "running",
	# }

	class { 'postgresql::globals':
                user => 'pgsql',
                group => 'pgsql',
  }->class { 'postgresql::server':
  }
}

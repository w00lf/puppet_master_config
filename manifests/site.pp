import "classes/*.pp"
filebucket { main: server => "puppet-master.ddc.local" }
File { backup => main }
Exec { path => "/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin" }
if $operatingsystem == 'FreeBSD' {
	$majorversion = regsubst($kernelversion, '^([0-9]+)\.([0-9]+)$', '\1')
	$scheme = 'http'
	$host   = 'ftp.freebsd.org'
	$urlpath = "/pub/FreeBSD/ports/${hardwareisa}/packages-${majorversion}-stable/"
	Package { source => "${scheme}://${host}/${urlpath}" }
}
node /^puppet.+agent\d?\.ddc\.local$/  {
	include sudoers
  include packages
	include psql_managment

	$whisper_dirs = [ "/usr/local/whisper/", "/usr/local/whisper/2.0",
                  "/usr/local/whisper/2.0/bin", "/usr/local/whisper/2.0/log",
                ]
	file { $whisper_dirs:
	    	ensure => "directory",
    		owner  => "root",
    		group  => "wheel",
    		mode   => 750,
	}
	$hello_file_path = $whisper_dirs[3]
	$hello_full_file_path = "$hello_file_path/hello_world.txt"
	file { $hello_full_file_path:
		owner => "root",
		mode => 644,
		ensure  => present,
      		content => "Hi. I am in /usr/local",
	}
}
# comment
node "puppet-master.ddc.local" {
	include packages
}

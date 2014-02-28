import "classes/*.pp"
filebucket { main: server => "puppet-master.ddc.local" }
File { backup => main }
Exec { path => "/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin" }
# if $operatingsystem == 'FreeBSD' {
# 	$majorversion = regsubst($kernelversion, '^([0-9]+)\.([0-9]+)$', '\1')
# 	$scheme = 'http'
# 	$host   = 'ftp.freebsd.org'
# 	$urlpath = "/pub/FreeBSD/ports/${hardwareisa}/packages-${kernelversion}-release/"
# 	Package { source => "${scheme}://${host}/${urlpath}", provider => 'freebsd' }
# }
node /^puppet.+agent\d?\.ddc-media\.local$/  {
  #   ->
  # class {"psql_managment":}
  class {"packages":} ->
  class {"node_register":}
}
# comment
node "puppet-master.ddc-media.local" {
	include packages
}

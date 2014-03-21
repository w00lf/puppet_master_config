# master mac: 080027ADF32D
# agent: 080027644FDE  || 080027C06563
import "classes/*.pp"
filebucket { main: server => "puppet-master.ddc.local" }
File { backup => main }
Exec { path => "/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin" }
if $operatingsystem == 'FreeBSD' {
	$majorversion = regsubst($kernelversion, '^([0-9]+)\.([0-9]+)$', '\1')
	$scheme = 'http'
	$host   = 'ftp.freebsd.org'
	$urlpath = "/pub/FreeBSD/ports/${hardwareisa}/packages-${kernelversion}-release/"
	Package { source => "${scheme}://${host}/${urlpath}", provider => 'freebsd' }
}
node /^puppet.+agent\d?\.ddc-media\.local$/  {
  $project_path = "${deploy_path}/distribution"
  #class{ "gems_pack":} ->
  class {"packages":} ->
  class {"database_managment":} ->
  class {"node_register":}->
  class {'murder_setup':}->
  class {'nginx_setup':}->
  class {'mcollective_setup':}
}
# comment
node "puppet-master.ddc-media.local" {
  package { ['bundler', 'murder', 'capistrano', 'bzip2-ruby-rb20', 'pg', 'activerecord']:
     ensure   => 'installed',
     provider => 'gem',
     source => 'http://rubygems.org',
  } ->
	class{"packages":}->
  class {'database_managment':}->
  exec{'craete nodes base':
    command => 'cd /usr/local/etc/puppet/ruby/lib/tasks && rake db:migrate',
    logoutput => true,
  }
}

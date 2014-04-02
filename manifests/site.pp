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
  $deploy_path = '/usr/local/www'
  $project_path = "${deploy_path}/distribution"
  $db_user = 'orfograph'
  $db_user_passwd = 'orfograph'
  $database = 'orfograph'
  $server_user = 'mik'

  class{ "gems_pack":} ->
  class {"packages":} ->
  class {"database_managment":
    db_user => $db_user,
    db_user_passwd => $db_user_passwd,
    database => $database
  } ->
  class {"node_register":}->
  class {"project_directory_setup":
    db_user => $db_user,
    db_user_passwd => $db_user_passwd,
    database => $database,
    project_path => $project_path,
    server_user => $server_user
  }->
  class{'btsync':
    deploy_path => "${project_path}/shared",
    shared_dir => "${project_path}/shared/store/books"
  }->
  class {'murder_setup':
    deploy_path => $deploy_path
  }->
  class {'nginx_setup':
    server_user => $server_user
  }
  # class {'mcollective_setup':}   - installs ruby 1.9.3 !
  exec{'ln /usr/local/bin/python2.7 /usr/local/bin/python2':
    unless => 'which python2'
  }
}
# comment
node "puppet-master.ddc-media.local" {
  #  package { ['bundler', 'murder', 'capistrano', 'bzip2-ruby-rb20', 'pg', 'activerecord']:
  #     ensure   => 'installed',
  #     provider => 'gem',
  #     source => 'http://rubygems.org',
  #  } ->
  # class{"packages":}->
  #  class {'database_managment':}->
  #  exec{'craete nodes base':
  #    command => 'cd /usr/local/etc/puppet/ruby/lib/tasks && rake db:migrate',
  #    logoutput => true,
  #  }->
  class {"node_register":}
  $deploy_path = '/usr/local/www'
  $project_path = "${deploy_path}/distribution"
  $db_user = 'orfograph'
  $db_user_passwd = 'orfograph'
  $database = 'orfograph'
  $server_user = 'mik'

  class {"project_directory_setup":
    db_user => $db_user,
    db_user_passwd => $db_user_passwd,
    database => $database,
    project_path => $project_path,
    server_user => $server_user
  }->
  class{'btsync':
    deploy_path => "${project_path}/shared",
    shared_dir => "${project_path}/shared/store"
  }
}

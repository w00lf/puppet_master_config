class database_managment($db_user, $database, $db_user_passwd) {
	# $db_user = 'orfograph'
 #  $db_user_passwd = 
	# $database = 'orfograph'

	$psql_command = 'psql'
	$dump_path = "/tmp/orfograph.sql"

	postgresql::server::role { $db_user:
  	password_hash => postgresql_password($db_user, $database),
	}->
	postgresql::server::db { $database:
	  user     => $db_user,
	  password => postgresql_password($db_user, $database),
	}->
  file{
    '/tmp/orfograph.tgz':
    ensure => present,
    source => "puppet:///files/orfograph.tgz"
  }->
  exec{'extract dump':
    logoutput => true,
    command => 'tar -xzf /tmp/orfograph.tgz -C /tmp/'
  }->
	exec {"load data in current db":
    logoutput => true,
    command => "${psql_command} -U ${db_user} -d ${database} < ${dump_path}",
  }
}

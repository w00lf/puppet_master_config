class database_managment {
	$db_user = 'orfograph'
	$database = 'orfograph'
	$psql_command = 'psql'
	$dump_path = "/tmp/structure.sql"

	postgresql::server::role { $db_user:
  	password_hash => postgresql_password($db_user, $database),
	}->
	postgresql::server::db { $database:
	  user     => $db_user,
	  password => postgresql_password($db_user, $database),
	}->
	file{'original_dump':
    path =>  $dump_path,
    ensure => present,
    source => "puppet:///files/structure.sql"

  }
	exec {"load data in current db":
    logoutput => true,
    command => "${psql_command} -U ${db_user} -d ${database} < ${dump_path}",
    require => File["original_dump"]
  }
}

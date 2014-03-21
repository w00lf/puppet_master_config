class db_switcher{
  $psql_command = 'psql -Upgsql '
  $database_name = 'testdatabse'
  $check_db_command = "[ `${psql_command} -l | grep ${database_name} | wc -l` = '1' ]"
    exec { "purge ${database_name}":
    command     => "${psql_command} -dpostgres -c 'drop database ${database_name}'",
    logoutput => true,
    onlyif => $check_db_command
  }
  $psql_current_database = inline_template("orfograph_<%= Time.now.strftime('%Y_%m_%d_%H_%M') %>")
  exec { "create current database: ${psql_current_database}":
    command     => "${psql_command} -dpostgres -c 'create database ${psql_current_database}'",
    logoutput => true,
  }
  $clean_old_db_command = "${psql_command} -l | egrep '(orfograph)' | grep -v ${psql_current_database} | awk '{print \$1}' | xargs -I {} psql -Upgsql -dpostgres -c \"drop database {}\""
  exec {"remove_old_databases":
    logoutput => true,
    command => $clean_old_db_command
  }
  file{'current dump':
    path => "${projects_path}${current_project}/tmp/current_dump.sql" ,
    ensure => present,
    source => "puppet:///files/current_dump.sql"

  }
  exec {"load data in current db":
    logoutput => true,
    command => "${psql_command} -d ${psql_current_database} < ${projects_path}${current_project}/tmp/current_dump.sql",
    require => File["current dump"]
  }
  #this is comment
  Exec["create current database: ${psql_current_database}"] -> Exec["load data in current db"] -> Exec["remove_old_databases"]
  $psql_username = 'pgsql'
  $projects_path = '/usr/local/www/'
  $current_project = 'test_debug'
  file {'new config':
    ensure => present,
    owner => 'root',
    require => Exec["create current database: ${psql_current_database}"],
    path => "${projects_path}${current_project}/config/database.yml",
    content => template('database.erb')
  }
}
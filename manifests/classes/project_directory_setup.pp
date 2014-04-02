class project_directory_setup($project_path, $database, $db_user, $db_user_passwd, $server_user) {
  file{
    [
      $project_path,
      "${project_path}/shared",
      "${project_path}/public", 
      "${project_path}/public/uploads",
      "${project_path}/shared/store",
      "${project_path}/shared/store/books",
      "${project_path}/shared/store/encrypted_books/"
    ]:
    owner  => "mik",
    ensure => directory,
    mode   => 777,      
  }
  file{"${project_path}/shared/unicorn.rb":
    owner  => "mik",
    ensure => present,
    content => template('unicorn.erb')   
  }

  file {"${project_path}/shared/database.yml":
    ensure => present,
    owner => 'mik',
    content => template('database.erb')
  }
}
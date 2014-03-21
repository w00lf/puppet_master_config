class nginx_setup{
  $nginx_root = '/usr/local/etc/nginx'
  $domain_name = $::fqdn

  package {'www/nginx':
        ensure   => installed,
        provider => 'freebsd'
  }->
  file{"${nginx_root}/domains":
    ensure => directory
  }->
  file{"${nginx_root}/domains/${domain_name}.conf":
    ensure => "present",
    content => template('nginx_domain.conf.erb')
  }->
  file{"${nginx_root}/nginx.conf":
    ensure => "present",
    content => template('nginx.conf.erb')
  }->
  file{'/var/log/nginx/':
    ensure => directory
  }->
  service {'nginx':
    ensure => "running",
  }
}
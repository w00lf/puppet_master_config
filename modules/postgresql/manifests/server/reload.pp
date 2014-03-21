# PRIVATE CLASS: do not use directly
class postgresql::server::reload {
  $ensure         = $postgresql::server::ensure
  $service_name   = $postgresql::server::service_name
  $service_status = $postgresql::server::service_status

  if($ensure == 'present' or $ensure == true) {
    exec { 'postgresql_reload':
      path        => '/usr/bin:/usr/sbin:/bin:/sbin',
      command     => "service ${service_name} stop && service ${service_name} start",
      onlyif      => $service_status,
      refreshonly => true,
    }
  }
}

# == Class: openvpn_as
#
class openvpn_as (
  $package_version                      = 'latest',
  $service_ensure                       = 'running',
  $service_refresh                      = true,
  $use_mysql                            = false,
  $mysql_username                       = 'openvpn',
  $mysql_password                       = 'defaultpassword',
  $mysql_host                           = 'localhost',
  $admin_ui_https_port                  = '943',
  $cs_https_port                        = '8443',
  $use_custom_port_config               = false,
  $vpn_client_basic                     = 'false',
  $vpn_daemon_0_client_network          = '172.27.240.0',
  $vpn_server_routing_private_network_0 = '10.0.0.0/24',
  $vpn_client_routing_reroute_dns       = 'false',
  $vpn_client_routing_reroute_gw        = 'false',
  $vpn_server_google_auth_enable        = 'false',
  $vpn_server_port_share_service        = 'custom',
  $host_name                            = $hostname,
  $admin_users                          = [],
) {

  if $service_refresh {
    class { 'openvpn_as::package': } ~>
    class { 'openvpn_as::config': } ~>
    class { 'openvpn_as::service': } ~>
    Class['openvpn_as']
  } else {
    class { 'openvpn_as::package': } ~>
    class { 'openvpn_as::config': } ->
    class { 'openvpn_as::service': } ->
    Class['openvpn_as']
  }

}

# == Class: openvpn_as
#
class openvpn_as (
  $package_version                      = 'latest',
  $service_ensure                       = 'running',
  $use_mysql                            = false,
  $mysql_username                       = 'openvpn',
  $mysql_password                       = 'defaultpassword',
  $mysql_host                           = 'localhost',
  $vpn_client_basic                     = 'false',
  $vpn_daemon_0_client_network          = '172.27.240.0',
  $vpn_server_routing_private_network_0 = '10.0.0.0/24',
  $vpn_client_routing_reroute_dns       = 'false',
  $vpn_client_routing_reroute_gw        = 'false',
  $vpn_server_google_auth_enable        = 'false',
  $host_name                            = $hostname,
  $admin_users                          = [],
) {

  class { 'openvpn_as::package': } ~>
  class { 'openvpn_as::config': } ~>
  class { 'openvpn_as::service': } ~>
  Class['openvpn_as']

}

# == Class: openvpn_as::config
#
class openvpn_as::config(
  $mysql_username                       = $openvpn_as::mysql_username,
  $mysql_password                       = $openvpn_as::mysql_password,
  $mysql_host                           = $openvpn_as::mysql_host,
  $vpn_daemon_0_client_network          = $openvpn_as::vpn_daemon_0_client_network,
  $vpn_client_basic                     = $openvpn_as::vpn_client_basic,
  $vpn_server_routing_private_network_0 = $openvpn_as::vpn_server_routing_private_network_0,
  $vpn_client_routing_reroute_dns       = $openvpn_as::vpn_client_routing_reroute_dns,
  $vpn_client_routing_reroute_gw        = $openvpn_as::vpn_client_routing_reroute_gw,
  $vpn_server_google_auth_enable        = $openvpn_as::vpn_server_google_auth_enable,
  $host_name                            = $openvpn_as::host_name,
  $admin_users                          = $openvpn_as::admin_users,
) {

  # Prepapre the database paths (MySQL or SQLite):
  if $openvpn_as::use_mysql {
    $openvpn_certs_db     = "mysql://${openvpn_mysql_username}:${openvpn_mysql_password}@${openvpn_mysql_host}/as_certs"
    $openvpn_user_prop_db = "mysql://${openvpn_mysql_username}:${openvpn_mysql_password}@${openvpn_mysql_host}/as_userprop"
    $openvpn_config_db    = "mysql://${openvpn_mysql_username}:${openvpn_mysql_password}@${openvpn_mysql_host}/as_config"
    $openvpn_log_db       = "mysql://${openvpn_mysql_username}:${openvpn_mysql_password}@${openvpn_mysql_host}/as_log"
  } else {
    $openvpn_certs_db     = 'sqlite:///~/db/certs.db'
    $openvpn_user_prop_db = 'sqlite:///~/db/userprop.db'
    $openvpn_config_db    = 'sqlite:///~/db/config.db'
    $openvpn_log_db       = 'sqlite:///~/db/log.db'
  }

  # This is used to "loop" over $admin_users:
  define mark_admin_users {
    $admin_user = $name
    notify { "Admin VPN user: $admin_user":; }

    # Use the sacli command to mark this user as an admin:
    exec { "openvpn-admin-user-${admin_user}":
      command => "/usr/local/openvpn_as/scripts/sacli --user '${admin_user}' --key prop_superuser --value true UserPropPut && touch /tmp/openvpn.admin_user.${admin_user}",
      creates => "/tmp/openvpn.admin_user.${admin_user}",
    }
  }

  # OpenVPN-AS config file:
  file { '/usr/local/openvpn_as/etc/as.conf':
    content => template('openvpn_as/as.conf.erb'),
    owner   => root,
    group   => root,
    mode    => '0644',
  }

  # Script to update config in MySQL:
  file { '/usr/local/openvpn_as/scripts/convert_config.sh':
    content => template('openvpn_as/move-data-to-mysql.sh.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
  }

  # Enable OpenVPN-Connect clients to have multiple profiles:
  file { '/usr/local/openvpn_as/openvpn.vpn.client.basic':
    content => "${vpn_client_basic}",
  } ~>
  exec { 'openvpn-vpn-client-basic':
    command     => "/usr/local/openvpn_as/scripts/confdba -mk vpn.client.basic -v '${vpn_client_basic}' && touch /tmp/openvpn.vpn.client.basic",
    refreshonly => true,
  }

  # Configure OpenVPN to know the internal network address of the VPC:
  file { '/usr/local/openvpn_as/openvpn.vpn.server.routing.private_network.0':
    content => "${vpn_server_routing_private_network_0}",
  } ~>
  exec { 'openvpn-vpn-server-routing-private-network-0':
    command     => "/usr/local/openvpn_as/scripts/confdba -mk vpn.server.routing.private_network.0 -v '${vpn_server_routing_private_network_0}' && touch /tmp/openvpn.vpn.server.routing.private_network.0",
    refreshonly => true,
  }

  # Configure OpenVPN to use a specific address-range for clients:
  file { '/usr/local/openvpn_as/openvpn.vpn.daemon.0.client.network':
    content => "${vpn_daemon_0_client_network}",
  } ~>
  exec { 'openvpn-vpn-daemon-0-client-network':
    command     => "/usr/local/openvpn_as/scripts/confdba -mk vpn.daemon.0.client.network -v '${vpn_daemon_0_client_network}' && touch /tmp/openvpn.vpn.daemon.0.client.network",
    refreshonly => true,
  }

  # Tell OpenVPN not to change clients DNS resolver settings:
  file { '/usr/local/openvpn_as/openvpn.vpn.client.routing.reroute_dns':
    content => "${vpn_client_routing_reroute_dns}",
  } ~>
  exec { 'openvpn-vpn-client-routing-reroute-dns':
    command     => "/usr/local/openvpn_as/scripts/confdba -mk vpn.client.routing.reroute_dns -v '${vpn_client_routing_reroute_dns}' && touch /tmp/openvpn.vpn.client.routing.reroute_dns",
    refreshonly => true,
  }

  # Tell OpenVPN not to route clients internet-traffic over the VPN:
  file { '/usr/local/openvpn_as/openvpn.vpn.client.routing.reroute_gw':
    content => "${vpn_client_routing_reroute_gw}",
  } ~>
  exec { 'openvpn-vpn-client-routing-reroute-gw':
    command     => "/usr/local/openvpn_as/scripts/confdba -mk vpn.client.routing.reroute_gw -v '${vpn_client_routing_reroute_gw}' && touch /tmp/openvpn.vpn.client.routing.reroute_gw",
    refreshonly => true,
  }

  # Tell OpenVPN to force clients to use a Google-Authenticator token:
  file { '/usr/local/openvpn_as/openvpn.vpn.server.google_auth.enable':
    content => "${vpn_server_google_auth_enable}",
  } ~>
  exec { 'openvpn-vpn-server-google-auth-enable':
    command     => "/usr/local/openvpn_as/scripts/confdba -mk vpn.server.google_auth.enable -v '${vpn_server_google_auth_enable}' && touch /tmp/openvpn.vpn.server.google_auth.enable",
    refreshonly => true,
  }

  # Tell OpenVPN what our external host-name is:
  file { '/usr/local/openvpn_as/openvpn.host.name':
    content => "${host_name}",
  } ~>
  exec { 'openvpn-host-name':
    command     => "/usr/local/openvpn_as/scripts/confdba -mk host.name -v '${host_name}' && touch /tmp/openvpn.host.name",
    refreshonly => true,
  }

  # Mark users as being "admin" users (for loop please):
  openvpn_as::config::mark_admin_users { $admin_users:; }

  # Meaningless file used to trigger a service-restart if any of these options are modified:
  file { '/usr/local/openvpn_as/etc/cruft.cft':
    content => template('openvpn_as/all-config-vars.erb'),
    owner   => root,
    group   => root,
    mode    => '0440',
  }

  # Enable IP-forwarding using the sysctl module (required to route traffic):
  sysctl { 'net.ipv4.ip_forward': value => 1 }

}

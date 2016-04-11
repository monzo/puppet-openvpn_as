# Puppet module for OpenVPN-AS

OpenVPN-AS (<https://openvpn.net/index.php/access-server/overview.html>) is "a full featured secure network tunneling VPN software solution that integrates OpenVPN server capabilities, enterprise management capabilities, simplified OpenVPN Connect UI, and OpenVPN Client software packages that accommodate Windows, MAC, Linux, Android, and iOS environments. OpenVPN Access Server supports a wide range of configurations, including secure and granular remote access to internal network and/ or private cloud network resources and applications with fine-grained access control."

## Sample profile using this module:
```
# == Class: profile::vpn::user
#
class profile::vpn::user {

  # Install the OpenVPN-AS service:
  class { '::openvpn_as':
    vpn_daemon_0_client_network          => '172.27.240.0',
    vpn_server_routing_private_network_0 => '10.3.0.0/16',
    vpn_server_google_auth_enable        => true,
    host_name                            => 'vpn.company.com',
    admin_users                          => ['prawn', 'dancannon']
  }

}
```

## Dependencies:
* "sysctl" module (allows ip-forwarding to be enabled)
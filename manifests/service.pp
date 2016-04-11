# == Class: openvpn_as::service
#
class openvpn_as::service {

  # Reset server:
  exec { 'openvpn-as-reset':
    command => '/usr/local/openvpn_as/scripts/sacli Reset',
    refreshonly => true,
  }

  # The OpenVPN-AS service:
  service { 'openvpnas':
    ensure => $openvpn_as::service_ensure,
    enable => true,
  }

}

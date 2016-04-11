# == Class: openvpn_as::package
#
class openvpn_as::package {

  # The OpenVPN-AS package:
  package { 'openvpn-as':
    ensure  => $openvpn_as::package_version
  }

}

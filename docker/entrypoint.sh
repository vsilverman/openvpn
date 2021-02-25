#!/bin/bash

set -e

OPENVPN_CONF_DIR='/etc/openvpn/server'

function configure_tun {
  [ -d /dev/net ] ||
    mkdir -p /dev/net
  [ -c /dev/net/tun ] ||
    mknod /dev/net/tun c 10 200
}

function configure_certificates {
  # if [ ! -f '/etc/ldap/ssl/cacert.crt' ]; then
  #   : "${OPENVPN_LDAP_CA_PEM:? Missing OPENVPN_LDAP_CA_PEM}"
  #   echo "$OPENVPN_LDAP_CA_PEM" > /etc/ldap/ssl/cacert.crt
  # fi

  if [ ! -f '/etc/openvpn/server/ca.crt' ]; then
    : "${OPENVPN_CA_PEM:? Missing OPENVPN_CA_PEM}"
    echo "$OPENVPN_CA_PEM" > /etc/openvpn/server/ca.crt
  fi

  if [ ! -f '/etc/openvpn/server/server.key' ]; then
    : "${OPENVPN_SERVER_KEY:? Missing OPENVPN_SERVER_KEY }"
    echo "$OPENVPN_SERVER_KEY" > /etc/openvpn/server/server.key
  fi

  if [ ! -f '/etc/openvpn/server/server.crt' ]; then
    : "${OPENVPN_SERVER_PEM:? Missing OPENVPN_SERVER_PEM }"
    echo "$OPENVPN_SERVER_PEM" > /etc/openvpn/server/server.crt
  fi

  if [ ! -f '/etc/openvpn/server/dh.pem' ]; then
    : "${OPENVPN_DH_PEM:? Missing OPENVPN_DH_PEM }"
    echo "$OPENVPN_DH_PEM" > /etc/openvpn/server/dh.pem
  fi
}

function ensure_required_variables {
  : "${AUTH_LDAP_PASSWORD:? AUTH_LDAP_PASSWORD required}"
  : "${AUTH_LDAP_URL:? AUTH_LDAP_URL required}"
  : "${AUTH_LDAP_BINDDN:? AUTH_LDAP_BINDDN required}"
  : "${AUTH_LDAP_GROUPS_MEMBER:? AUTH_LDAP_GROUPS_MEMBER required}"
}

# Use ~ in order to avoid wrong interpration with / in sed command.
# Sed should be replaced by something more robust in the futur.

function configure_openvpn {
  sed -i "s~AUTH_LDAP_PASSWORD~$AUTH_LDAP_PASSWORD~g" "$OPENVPN_CONF_DIR/auth-ldap.conf"
  sed -i "s~AUTH_LDAP_URL~$AUTH_LDAP_URL~g" "$OPENVPN_CONF_DIR/auth-ldap.conf"
  sed -i "s~AUTH_LDAP_BINDDN~$AUTH_LDAP_BINDDN~g" "$OPENVPN_CONF_DIR/auth-ldap.conf"
  sed -i "s~AUTH_LDAP_GROUPS_MEMBER~$AUTH_LDAP_GROUPS_MEMBER~g" "$OPENVPN_CONF_DIR/auth-ldap.conf"
}

function start_openvpn {
  openvpn --config "$OPENVPN_CONF_DIR/server.conf"
}

ensure_required_variables
configure_tun
configure_certificates
configure_openvpn
start_openvpn

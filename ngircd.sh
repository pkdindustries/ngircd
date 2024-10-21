#!/bin/sh

# Set default values
: "${IRCD_NAME:="soulshack.irc"}"
: "${IRCD_INFO:="Default Info"}"
: "${IRCD_MOTD:="Welcome to the IRC server!"}"
: "${IRCD_NETWORK:="DefaultNetwork"}"
: "${IRCD_PORTS:="6667"}"

# Write the configuration file
cat <<EOF > /ngircd.conf
[Global]
Name = ${IRCD_NAME}
Info = ${IRCD_INFO}
Listen = 0.0.0.0
MotdPhrase = ${IRCD_MOTD}
Network = ${IRCD_NETWORK}
Ports = ${IRCD_PORTS}
ServerGID = nobody
ServerUID = nobody

[Limits]
MaxListSize = 100
PingTimeout = 120

[Options]
DNS = yes
PAM = no

[SSL]
${IRCD_SSL_CERT_FILE:+CertFile = ${IRCD_SSL_CERT_FILE}}
${IRCD_SSL_KEY_FILE:+KeyFile = ${IRCD_SSL_KEY_FILE}}
${IRCD_SSL_KEYFILE_PASSWORD:+KeyFilePassword = ${IRCD_SSL_KEYFILE_PASSWORD}}
${IRCD_SSL_PORTS:+Ports = ${IRCD_SSL_PORTS}}

[Server]
SSLVerify = no
SSLConnect = yes
${IRCD_LINK_NAME:+Name = ${IRCD_LINK_NAME}}
${IRCD_LINK_HOST:+Host = ${IRCD_LINK_HOST}}
${IRCD_LINK_PORT:+Port = ${IRCD_LINK_PORT}}
${IRCD_LINK_PASSWORD:+MyPassword = ${IRCD_LINK_PASSWORD}}
${IRCD_LINK_PEER_PASSWORD:+PeerPassword = ${IRCD_LINK_PEER_PASSWORD}}
EOF

# Test config
/usr/sbin/ngircd -f /ngircd.conf -t

# Start ngIRCd with debug logging
exec /usr/sbin/ngircd -f /ngircd.conf -n -d

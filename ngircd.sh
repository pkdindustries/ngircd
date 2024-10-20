#!/bin/sh

# Set default values
if [ -z "$IRCD_NAME" ]; then
    export IRCD_NAME="soulshack.irc"
fi

# Handle SSL configuration
IRCD_SSL_CONFIG=""
if [ -n "$IRCD_SSL_CERT_FILE" ]; then
    IRCD_SSL_CONFIG="${IRCD_SSL_CONFIG}CertFile = ${IRCD_SSL_CERT_FILE}
"
fi
if [ -n "$IRCD_SSL_KEY_FILE" ]; then
    IRCD_SSL_CONFIG="${IRCD_SSL_CONFIG}KeyFile = ${IRCD_SSL_KEY_FILE}
"
fi
if [ -n "$IRCD_SSL_KEYFILE_PASSWORD" ]; then
    IRCD_SSL_CONFIG="${IRCD_SSL_CONFIG}KeyFilePassword = ${IRCD_SSL_KEYFILE_PASSWORD}
"
fi
if [ -n "$IRCD_SSL_PORTS" ]; then
    IRCD_SSL_CONFIG="${IRCD_SSL_CONFIG}Ports = ${IRCD_SSL_PORTS}
"
fi

# Handle server link configuration
IRCD_LINK_CONFIG=""
if [ -n "$IRCD_LINK_NAME" ]; then
    IRCD_LINK_CONFIG="${IRCD_LINK_CONFIG}Name = ${IRCD_LINK_NAME}
"
fi
if [ -n "$IRCD_LINK_HOST" ]; then
    IRCD_LINK_CONFIG="${IRCD_LINK_CONFIG}Host = ${IRCD_LINK_HOST}
"
fi
if [ -n "$IRCD_LINK_PORT" ]; then
    IRCD_LINK_CONFIG="${IRCD_LINK_CONFIG}Port = ${IRCD_LINK_PORT}
"
fi
if [ -n "$IRCD_LINK_PASSWORD" ]; then
    IRCD_LINK_CONFIG="${IRCD_LINK_CONFIG}MyPassword = ${IRCD_LINK_PASSWORD}
"
fi
if [ -n "$IRCD_LINK_PEER_PASSWORD" ]; then
    IRCD_LINK_CONFIG="${IRCD_LINK_CONFIG}PeerPassword = ${IRCD_LINK_PEER_PASSWORD}
"
fi

export IRCD_LINK_CONFIG
export IRCD_SSL_CONFIG

echo "Writing ngircd.conf"
envsubst < /ngircd.conf.tmpl > /ngircd.conf

cat /ngircd.conf
/usr/sbin/ngircd -f /ngircd.conf -t
ls -lsd /ngircd* /certs
ls -ls /certs/*
ls -lsd /ngircd/
ls -ls /ngircd/*
# Start ngIRCd with debug logging
exec /usr/sbin/ngircd -f /ngircd.conf -n -d

#!/bin/sh 
if [ -z "$IRCD_NAME" ]; then
    export IRCD_NAME="default.irc"
fi

echo "writing ngircd.conf" 
envsubst <ngircd.conf.tmpl >ngircd.conf
exec /usr/sbin/ngircd -f /ngircd.conf -n

#!/bin/sh

set -e

COMMAND=ash

if [ -n "$DEBUG" ]; then
  set -x
fi

if [ -z "$SAMBA_DC_NETBIOS_NAME" ]; then
  SAMBA_DC_NETBIOS_NAME=$(hostname -s | tr [a-z] [A-Z])
else
  SAMBA_DC_NETBIOS_NAME=$(echo "$SAMBA_DC_NETBIOS_NAME" | tr [a-z] [A-Z])
fi

SAMBA_DC_REALM=$(echo "$SAMBA_DC_REALM" | tr [a-z] [A-Z])

if [ -z "$SAMBA_DC_IP" ]; then
  SAMBA_DC_IP=$(hostname -i|xargs)
fi

# Add $COMMAND if needed
if [ "${1:0:1}" = '-' ]; then
  set -- $COMMAND "$@"
fi

# Configure the AD DC
if [ ! -f /etc/samba/smb.conf.lock ]; then
  if [ "$BIND_INTERFACES_ONLY" = "yes" ]; then
    INTERFACE_OPTS="--option=\"bind interfaces only=yes\" \
      --option=\"interfaces=$INTERFACES\""
  fi
  if [ -n "$SAMBA_DC_IP" ]; then
    HOSTIP_OPTION="--host-ip=$SAMBA_DC_IP"
  else
    HOSTIP_OPTION=""
  fi
  echo "${SAMBA_DC_DOMAIN} - Begin Domain Provisioning"
  echo "samba-tool domain provision --domain=${SAMBA_DC_DOMAIN} \
    --use-rfc2307 \
    --adminpass=${SAMBA_DC_ADMIN_PASSWORD} \
    --server-role=dc \
    --realm=${SAMBA_DC_REALM} \
    --dns-backend=SAMBA_INTERNAL $HOSTIP_OPTION $INTERFACE_OPTS" | sh

  mv /etc/samba/smb.conf /etc/samba/smb.conf.lock

  echo "${SAMBA_DC_DOMAIN} - Domain Provisioned Successfully"
fi

mkdir -p /etc/samba/conf.d

for file in /etc/samba/smb.conf /etc/samba/conf.d/netlogon.conf \
      /etc/samba/conf.d/sysvol.conf; do
  sed -e "s:{{ ALLOW_DNS_UPDATES }}:$ALLOW_DNS_UPDATES:" \
      -e "s:{{ BIND_INTERFACES_ONLY }}:$BIND_INTERFACES_ONLY:" \
      -e "s:{{ DNS_FORWARDER }}:$SAMBA_DC_DNS_FORWARDER:" \
      -e "s:{{ DOMAIN_LOGONS }}:$DOMAIN_LOGONS:" \
      -e "s:{{ DOMAIN_MASTER }}:$DOMAIN_MASTER:" \
      -e "s+{{ INTERFACES }}+$INTERFACES+" \
      -e "s+{{ LOG_LEVEL }}+$LOG_LEVEL+" \
      -e "s:{{ NETBIOS_NAME }}:$SAMBA_DC_NETBIOS_NAME:" \
      -e "s:{{ REALM }}:${SAMBA_DC_REALM}:" \
      -e "s:{{ SERVER_STRING }}:$SERVER_STRING:" \
      -e "s:{{ DOMAIN }}:$SAMBA_DC_DOMAIN:" \
      -e "s:{{ WINBIND_USE_DEFAULT_DOMAIN }}:$WINBIND_USE_DEFAULT_DOMAIN:" \
      /tmp/conf/$(basename $file) > $file
done
for file in $(ls -A /etc/samba/conf.d/*.conf); do
  echo "include = $file" >> /etc/samba/smb.conf
done

cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

if [ "$1" = 'samba' ]; then
  exec /usr/sbin/samba -i
fi

# Assume that user wants to run their own process,
# for example a `bash` shell to explore this image
exec "$@"

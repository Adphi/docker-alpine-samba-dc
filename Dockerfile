FROM alpine:latest

# Install
RUN apk update && apk add --no-cache samba-dc chrony krb5 pam-winbind && \
    # Remove default config data, if any
    rm -rf /etc/samba/smb.conf

# Expose ports
EXPOSE 37/udp \
       53 \
       88 \
       135/tcp \
       137/udp \
       138/udp \
       139 \
       389 \
       445 \
       464 \
       636/tcp \
       1024-5000/tcp \
       3268/tcp \
       3269/tcp

ENV SAMBA_DC_DOMAIN=TEST \
    SAMBA_DC_REALM=ad.test.org \
    SAMBA_DC_ADMIN_PASSWORD='P4s$W0rd' \
    SAMBA_DC_IP="" \
    SAMBA_DC_DNS_FORWARDER=8.8.8.8 \
    SAMBA_DC_NETBIOS_NAME="" \
    ALLOW_DNS_UPDATES=secure \
    DOMAIN_LOGONS=yes \
    DOMAIN_MASTER=no \
    LOG_LEVEL="3 passdb:5 auth:5" \
    SERVER_STRING="Samba Domain Controller" \
    TZ=UTC \
    WINBIND_USE_DEFAULT_DOMAIN=yes \
    BIND_INTERFACES_ONLY=yes \
    INTERFACES="lo eth0"

# Persist the configuration, data and log directories
VOLUME ["/etc/samba", "/var/lib/samba", "/var/log/samba"]

# Copy & set entrypoint for manual access
COPY conf /tmp/conf
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["samba"]

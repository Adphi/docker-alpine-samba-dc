[![License: Apache 2.0](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0.html)
[![Build Status](https://travis-ci.org/LasLabs/docker-alpine-samba-dc.svg?branch=master)](https://travis-ci.org/LasLabs/docker-alpine-samba-dc)

[![](https://images.microbadger.com/badges/image/adphi/alpine-samba-dc.svg)](https://microbadger.com/images/adphi/alpine-samba-dc "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/adphi/alpine-samba-dc.svg)](https://microbadger.com/images/adphi/alpine-samba-dc "Get your own version badge on microbadger.com")

Docker - Alpine Samba Domain Controller
=======================================

This image provides a Samba 4 Domain Controller using an Alpine Linux base.

Configuration
=============
First, Pull the image:

```bash
docker pull adphi/alpine-samba-dc:0.1.0
```

Now, start the image with the correct environment variables for initial
configuration:

* Note that we're persisting the samba volume to a local directory named
`samba` in your working dir

```bash
mkdir ${PWD}/samba

ifconfig eth0:1 192.168.1.8 netmask 255.255.255.0 up

docker run -d --name samba-ad \
    --restart unless-stopped \
    --cap-add SYS_ADMIN \
    --hostname dc01 \
    --dns 127.0.0.1 \
    --dns-search=corp.example.net \
    -e SAMBA_DC_REALM='corp.example.net' \
    -e SAMBA_DC_DOMAIN='EXAMPLE' \
    -e SAMBA_DC_ADMIN_PASSWORD='5u3r53cur3!' \
    -e SAMBA_DC_IP=192.168.1.8 \
    -e SAMBA_DC_DNS_FORWARDER=8.8.8.8 \
    -v $(pwd)/data/etc:/etc/samba \
    -v $(pwd)/data/lib:/var/lib/samba \
    -v $(pwd)/data/log:/var/log/samba \
    -p 192.168.1.8:53:53 \
    -p 192.168.1.8:53:53/udp \
    -p 192.168.1.8:88:88 \
    -p 192.168.1.8:88:88/udp \
    -p 192.168.1.8:135:135 \
    -p 192.168.1.8:137-138:137-138/udp \
    -p 192.168.1.8:139:139 \
    -p 192.168.1.8:389:389 \
    -p 192.168.1.8:389:389/udp \
    -p 192.168.1.8:445:445 \
    -p 192.168.1.8:464:464 \
    -p 192.168.1.8:464:464/udp \
    -p 192.168.1.8:636:636 \
    -p 192.168.1.8:1024-1044:1024-1044 \
    -p 192.168.1.8:3268-3269:3268-3269 \
    'adphi/alpine-samba-dc'
```

Usage
=====
After the container has been run for the first time, invoke it with the following command

```bash
docker run -d --name samba-ad \
    --restart unless-stopped \
    --cap-add SYS_ADMIN \
    --hostname dc01 \
    --dns 127.0.0.1 \
    -v $(pwd)/samba/etc:/etc/samba \
    -v $(pwd)/samba/lib:/var/lib/samba \
    -v $(pwd)/samba/log:/var/log/samba \
    -p 192.168.1.8:53:53 \
	-p 192.168.1.8:53:53/udp \
	-p 192.168.1.8:88:88 \
	-p 192.168.1.8:88:88/udp \
	-p 192.168.1.8:135:135 \
	-p 192.168.1.8:137-138:137-138/udp \
	-p 192.168.1.8:139:139 \
	-p 192.168.1.8:389:389 \
	-p 192.168.1.8:389:389/udp \
	-p 192.168.1.8:445:445 \
	-p 192.168.1.8:464:464 \
	-p 192.168.1.8:464:464/udp \
	-p 192.168.1.8:636:636 \
	-p 192.168.1.8:1024-1044:1024-1044 \
	-p 192.168.1.8:3268-3269:3268-3269 \
     'adphi/alpine-samba-dc'
```

Volumes
=======

The following volumes are exposed:


| Name | Value | Description |
|------|-------|-------------|
| Samba | /samba | Re-homed Samba Config, data and log directory |

Environment Variables
=====================

The following environment variables are available for your configuration
pleasure:

| Name | Default | Description |
|------|---------|-------------|
| SAMBA_DC_REALM | corp.example.net | The realm to launch the DC into
| SAMBA_DC_DOMAIN | EXAMPLE | The NetBIOS Domain Name
| SAMBA_DC_ADMIN_PASSWD | 5u3r53cur3! | The AD DC `Administrator` user password
| SAMBA_DC_DNS_BACKEND | SAMBA_INTERNAL | The DNS backend to use


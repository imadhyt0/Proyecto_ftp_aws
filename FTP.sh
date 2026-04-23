#!/bin/bash
# Actualizar el sistema
apt-get update -y
apt-get upgrade -y

# Instalar ProFTPD y el módulo LDAP
apt-get install -y proftpd proftpd-mod-ldap

# Crear la carpeta de acceso público (Anónimo)
mkdir -p /srv/ftp/publico
chmod 755 /srv/ftp/publico
chown ftp:ftp /srv/ftp/publico

# (Más adelante inyectaremos aquí la configuración exacta del proftpd.conf)
systemctl enable proftpd
systemctl restart proftpd
#!/bin/bash
# 1. Actualizar e instalar ProFTPD y el módulo LDAP
apt-get update -y
apt-get install -y proftpd proftpd-mod-ldap

# 2. Obtener la IP Pública de AWS dinámicamente para el Modo Pasivo
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
IP_PUB=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)

# 3. Crear carpeta pública y dar permisos
mkdir -p /srv/ftp/publico
chmod 755 /srv/ftp/publico
chown ftp:ftp /srv/ftp/publico

# 4. Inyectar la configuración maestra de ProFTPD
cat <<EOF > /etc/proftpd/proftpd.conf
Include /etc/proftpd/modules.conf
UseIPv6 off
IdentLookups off
ServerName "Servidor FTP IES Iliberis"
ServerType standalone
DeferWelcome off
MultilineRFC2228 on
DefaultServer on
ShowSymlinks on
TimeoutNoTransfer 600
TimeoutStalled 600
TimeoutIdle 1200
Port 21
MaxInstances 30
User proftpd
Group nogroup
Umask 022 022
AllowOverwrite on

# --- SOLUCIÓN MODO PASIVO ---
PassivePorts 60000 65535
MasqueradeAddress $IP_PUB

# --- ENLACE CON LDAP ---
<IfModule mod_ldap.c>
  LDAPServer 10.1.1.50
  LDAPBindDN "cn=Manager,dc=my-domain,dc=com" "secret"
  LDAPUsers ou=usuarios,dc=my-domain,dc=com (uid=%v) (uidNumber=%v)
  LDAPDoAuth on "dc=my-domain,dc=com"
</IfModule>

# --- USUARIO ANÓNIMO ---
<Anonymous ~ftp>
  User ftp
  Group nogroup
  UserAlias anonymous ftp
  RequireValidShell off
  MaxClients 10
  <Directory *>
    <Limit WRITE>
      DenyAll
    </Limit>
  </Directory>
</Anonymous>
EOF

# 5. Reiniciar el servicio para aplicar los cambios
systemctl restart proftpd
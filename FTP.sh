#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Actualizar e instalar ProFTPD y el modulo LDAP
apt-get update -y
apt-get install -y proftpd proftpd-mod-ldap

# Quitar el comentario para activar el modulo LDAP
sed -i 's/^#\s*LoadModule mod_ldap.c/LoadModule mod_ldap.c/g' /etc/proftpd/modules.conf

# Sacar la IP publica de la maquina para el modo pasivo
IP_PUB=$(curl -s ifconfig.me)

# Crear la carpeta publica para el usuario anonymous
mkdir -p /srv/ftp/publico
chmod 755 /srv/ftp/publico
chown ftp:nogroup /srv/ftp/publico

# Crear las carpetas de los usuarios a mano para que no de el error 530
mkdir -p /home/senen
chown 1000:1000 /home/senen

mkdir -p /home/imad
chown 1001:1001 /home/imad

# Escribir la configuracion al final del archivo
cat <<EOF >> /etc/proftpd/proftpd.conf

# Configuracion general
DefaultRoot ~
RequireValidShell off
AuthPAM off

# Modo pasivo
PassivePorts 60000 65535
MasqueradeAddress $IP_PUB

# Conexion con la maquina LDAP privada
<IfModule mod_ldap.c>
  AuthOrder mod_ldap.c mod_auth_unix.c
  LDAPServer 10.1.1.50
  LDAPBindDN "cn=Manager,dc=my-domain,dc=com" "secret"
  LDAPUsers "ou=usuarios,dc=my-domain,dc=com" "(uid=%v)"
  
  # Para que el LDAP valide las contraseñas encriptadas
  LDAPAuthBinds on
  
  LDAPSearchScope subtree
  LDAPDefaultGID 1000
  LDAPDefaultUID 1000
  LDAPForceDefaultGID on
  LDAPForceDefaultUID on
</IfModule>

# Acceso para el usuario anonymous
<Anonymous /srv/ftp>
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

# Reiniciar el servicio para aplicar los cambios
systemctl restart proftpd
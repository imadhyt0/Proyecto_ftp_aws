#!/bin/bash
# 1. Actualizar e instalar OpenLDAP en Amazon Linux 2023
dnf update -y
dnf install -y openldap-servers openldap-clients

# 2. Copiar configuración base y arrancar el servicio
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown ldap:ldap /var/lib/ldap/DB_CONFIG
systemctl enable --now slapd

# 3. Crear el archivo LDIF con la estructura y los usuarios
cat <<EOF > /tmp/base.ldif
dn: dc=my-domain,dc=com
objectClass: top
objectClass: dcObject
objectclass: organization
o: Mi Proyecto FTP
dc: my-domain

dn: cn=Manager,dc=my-domain,dc=com
objectClass: organizationalRole
cn: Manager
description: Administrador del Directorio

dn: ou=usuarios,dc=my-domain,dc=com
objectClass: organizationalUnit
ou: usuarios

# --- USUARIO 1: SENEN (El Evaluador) ---
dn: uid=senen,ou=usuarios,dc=my-domain,dc=com
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: senen
uid: senen
uidNumber: 1000
gidNumber: 1000
homeDirectory: /home/senen
loginShell: /bin/bash
gecos: Estudiante IES Iliberis
userPassword: {CLEARTEXT}senen123

# --- USUARIO 2: IMAD (El Creador) ---
dn: uid=imad,ou=usuarios,dc=my-domain,dc=com
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: imad
uid: imad
uidNumber: 1001
gidNumber: 1001
homeDirectory: /home/imad
loginShell: /bin/bash
gecos: Estudiante IES Iliberis
userPassword: {CLEARTEXT}imad123
EOF

# 4. Inyectar los datos en la base de datos LDAP
ldapadd -x -D "cn=Manager,dc=my-domain,dc=com" -w secret -f /tmp/base.ldif
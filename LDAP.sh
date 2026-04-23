#!/bin/bash
set -e

echo ">>> [1/5] Instalar OpenLDAP..."
dnf update -y
dnf install -y openldap-servers openldap-clients

echo ">>> [2/5] Arrancando slapd..."
systemctl enable --now slapd
sleep 3

echo ">>> [3/5] Configurando dominio y contraseña (En 3 pasos seguros)..."
HASHED_PW=$(slappasswd -s secret)

# Operación 1: cambiar el dominio base
cat <<EOF > /tmp/config1.ldif
dn: olcDatabase={2}mdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=my-domain,dc=com
EOF

# Operación 2: cambiar el DN del administrador
cat <<EOF > /tmp/config2.ldif
dn: olcDatabase={2}mdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=Manager,dc=my-domain,dc=com
EOF

# Operación 3: poner la contraseña del administrador
cat <<EOF > /tmp/config3.ldif
dn: olcDatabase={2}mdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: $HASHED_PW
EOF

# --- ESCUDO ANTI-WINDOWS: Limpiamos los 3 archivos antes de inyectarlos ---
sed -i 's/\r//g' /tmp/config1.ldif /tmp/config2.ldif /tmp/config3.ldif

# Ejecutamos uno a uno (A prueba de balas)
ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/config1.ldif
ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/config2.ldif
ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/config3.ldif

echo ">>> [4/5] Cargando esquemas..."
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif

echo ">>> [5/5] Crear usuarios..."
PW_SENEN=$(slappasswd -s senen123)
PW_IMAD=$(slappasswd -s imad123)

cat <<EOF > /tmp/usuarios.ldif
dn: dc=my-domain,dc=com
objectClass: top
objectClass: dcObject
objectClass: organization
o: Mi Proyecto FTP
dc: my-domain

dn: cn=Manager,dc=my-domain,dc=com
objectClass: organizationalRole
cn: Manager

dn: ou=usuarios,dc=my-domain,dc=com
objectClass: organizationalUnit
ou: usuarios

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
userPassword: $PW_SENEN

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
userPassword: $PW_IMAD
EOF

# --- ESCUDO ANTI-WINDOWS: Limpiamos los usuarios ---
sed -i 's/\r//g' /tmp/usuarios.ldif

ldapadd -x -D "cn=Manager,dc=my-domain,dc=com" -w secret -f /tmp/usuarios.ldif

echo "Listo. Usuarios creados: senen y imad"
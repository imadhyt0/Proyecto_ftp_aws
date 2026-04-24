#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Actualizar e instalar ProFTPD y el modulo LDAP
apt-get update -y
apt-get install -y proftpd proftpd-mod-ldap

# Activar el modulo LDAP
sed -i 's/^#\s*LoadModule mod_ldap.c/LoadModule mod_ldap.c/g' /etc/proftpd/modules.conf

# Activar los modulos de cuotas
sed -i 's/^#\s*LoadModule mod_quotatab.c/LoadModule mod_quotatab.c/g' /etc/proftpd/modules.conf
sed -i 's/^#\s*LoadModule mod_quotatab_file.c/LoadModule mod_quotatab_file.c/g' /etc/proftpd/modules.conf

# El proftpd.conf original de Ubuntu tiene QuotaEngine off
# Si no lo cambiamos, anula nuestro QuotaEngine on de mas abajo
sed -i 's/QuotaEngine off/QuotaEngine on/' /etc/proftpd/proftpd.conf

# Sacar la IP publica de la maquina para el modo pasivo
IP_PUB=$(curl -s ifconfig.me)

# Crear la carpeta publica para el usuario anonymous
mkdir -p /srv/ftp/publico
chmod 755 /srv/ftp/publico
chown ftp:nogroup /srv/ftp/publico

# Crear los homes de los usuarios
# ProFTPD exige que la carpeta raiz del chroot sea de root:root con 755
# La subcarpeta uploads es donde el usuario realmente puede escribir
mkdir -p /home/senen/uploads
chown root:root /home/senen
chmod 755 /home/senen
chown 1000:1000 /home/senen/uploads
chmod 777 /home/senen/uploads

mkdir -p /home/imad/uploads
chown root:root /home/imad
chmod 755 /home/imad
chown 1001:1001 /home/imad/uploads
chmod 777 /home/imad/uploads

# Crear las tablas de cuotas
ftpquota --create-table --type=limit --table-path=/etc/proftpd/ftpquota.limittab
ftpquota --create-table --type=tally --table-path=/etc/proftpd/ftpquota.tallytab

# Asignar cuotas: imad 50MB, senen 100MB
ftpquota --add-record --type=limit --name=imad --quota-type=user \
  --bytes-upload=50 --bytes-download=0 --units=Mb \
  --table-path=/etc/proftpd/ftpquota.limittab

ftpquota --add-record --type=limit --name=senen --quota-type=user \
  --bytes-upload=100 --bytes-download=0 --units=Mb \
  --table-path=/etc/proftpd/ftpquota.limittab

# Dar permisos al usuario proftpd sobre las tablas
chown proftpd:nogroup /etc/proftpd/ftpquota.limittab
chown proftpd:nogroup /etc/proftpd/ftpquota.tallytab
chmod 640 /etc/proftpd/ftpquota.limittab
chmod 640 /etc/proftpd/ftpquota.tallytab

# Añadir configuracion al proftpd.conf
cat <<EOF >> /etc/proftpd/proftpd.conf

# Configuracion general
DefaultRoot ~
RequireValidShell off
AuthPAM off

# Modo pasivo
PassivePorts 60000 65535
MasqueradeAddress $IP_PUB

# Cuotas de disco por usuario
# imad puede subir max 50MB, senen max 100MB
<IfModule mod_quotatab.c>
  QuotaEngine on
  QuotaLog /var/log/proftpd/quota.log
  QuotaLimitTable file:/etc/proftpd/ftpquota.limittab
  QuotaTallyTable file:/etc/proftpd/ftpquota.tallytab
</IfModule>

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

# Node Exporter - expone metricas del sistema en el puerto 9100
cd /tmp
wget -q https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
tar -xzf node_exporter-1.8.1.linux-amd64.tar.gz
mv node_exporter-1.8.1.linux-amd64/node_exporter /usr/local/bin/
useradd -rs /bin/false node_exporter

cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now node_exporter
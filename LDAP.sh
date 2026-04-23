#!/bin/bash
# Actualizar Amazon Linux
dnf update -y

# Instalar OpenLDAP y las herramientas de cliente
dnf install -y openldap-servers openldap-clients

# Iniciar y habilitar el servicio
systemctl start slapd
systemctl enable slapd

# (Más adelante pondremos aquí los comandos para crear a "Senen" automáticamente)
#!/bin/bash

# Habilitar repositorios adecuados para sistemas Red Hat Enterprise Linux
# Si instalaras la version comunitaria, no es necesario este apartado
subscription-manager repos --disable="*"
subscription-manager repos --enable="rhel-7-server-rpms"
subscription-manager repos --enable="rhel-7-server-extras-rpms"
subscription-manager repos --enable="rhel-7-server-ose-3.11-rpms"
subscription-manager repos --enable="rhel-7-server-ansible-2.6-rpms"

# Generar llave ssh en el host master
ssh-keygen 

# Enviar llave generada a cada host node que sera parte de nuestro cluster
# Si se desea que mas hosts nodes sean parte del cluster, agregarlos
# Los hostname deben ser reconocidos, ya sea un DNS o por el archivo /etc/hosts

for host in master01.server \
    node1.server \
    node2.server; \
    do ssh-copy-id -i ~/.ssh/id_rsa.pub $host; \
    done

# Instalar los paquetes bases 
yum install wget git net-tools bind-utils yum-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct -y
yum update -y
reboot

# Instalacion basada en RPM
yum install openshift-ansible -y

# Instalación Docker
yum install docker-1.13.1 -y

# Verificar Versión Docker
rpm -V docker-1.13.1
docker version

# Creación del docker-pool
cat <<EOF> /etc/sysconfig/docker-storage-setup
DEVS=/dev/vdb
VG=docker-vg
EOF

# Correr el script docker-storage-setup
docker-storage-setup

# Verificación de la configuración
cat /etc/sysconfig/docker-storage

# Habilitar e iniciar el servicio docker
systemctl enable docker
systemctl start docker
systemctl is-active docker

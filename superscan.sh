#!/bin/bash

# Verifica si el comando figlet está instalado
if ! command -v figlet &> /dev/null; then
echo "Error: El comando 'figlet' no está instalado. Por favor, ejecutar 'sudo apt-get install -y figlet'"
exit 1
fi

# Presentacion
figlet SuperScan
echo "by skipy95d"
echo

# Solicita al usuario que ingrese la IP del host a escanear
echo "Ingrese la IP del host a escanear:"
read host

# Crea una carpeta con el nombre del host
mkdir -p "$host"

# Define el nombre del archivo donde se guardara el resultado del escaneo
archivo="$host/resultado_escaneo.txt"

# Crea el archivo "resultado_escaneo.txt"
touch "$archivo"

# Inicia el escaneo de puertos con nmap
nmap -sCV -Pn --min-rate=5000 "$host" >> "$archivo"

# Verifica si los puertos 80 o 443 estan abiertos
if grep -q "80/tcp open" "$archivo" || grep -q "443/tcp open" "$archivo"; then
# Ejecuta el comando whatweb
whatweb "$host" >> "$archivo"
fi

# Verifica si los puertos 80 y 443 estan abiertos
if grep -q "80/tcp open" "$archivo" || grep -q "443/tcp open" "$archivo"; then
# Ejecuta el comando openssl por el puerto 80
openssl s_client -connect "$host":80 >> "$archivo"
# Ejecuta el comando openssl por el puerto 443
openssl s_client -connect "$host":443 >> "$archivo"
fi

# Verifica si el puerto 445 esta abierto
if grep -q "445/tcp open" "$archivo"; then

nmap -p 445 --script=smb-enum-shares.nse,smb-enum-users.nse "$host" >> "$archivo"
fi

# Verifica si los puertos 23 estan abiertos
if grep -q "23/tcp open" "$archivo"; then

nmap -n -sV -Pn --script "telnet and safe" -p 23 "$host" >> "$archivo"
fi

# Finalizando
echo
echo "carepeta creada con los resultados: "
ls
echo
echo "Escaneo finalizado."
exit 0;

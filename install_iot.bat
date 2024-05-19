@echo off

REM Crear carpeta general y subcarpetas
mkdir %USERPROFILE%\iot
mkdir %USERPROFILE%\iot\nodered
mkdir %USERPROFILE%\iot\grafana
mkdir %USERPROFILE%\iot\influxdb
mkdir %USERPROFILE%\iot\mariadb
mkdir %USERPROFILE%\iot\portainer
mkdir %USERPROFILE%\iot\adminer
mkdir %USERPROFILE%\iot\mosquitto

REM Instalar Docker Desktop
powershell -Command "Invoke-WebRequest -Uri https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe -OutFile DockerDesktopInstaller.exe"
start /wait DockerDesktopInstaller.exe install

REM Esperar a que Docker se instale y se inicie
timeout /t 20

REM Instalar Docker Compose
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Windows-x86_64.exe' -OutFile '%USERPROFILE%\docker-compose.exe'"
move %USERPROFILE%\docker-compose.exe C:\ProgramData\DockerDesktop\cli-plugins\docker-compose.exe

REM Crear archivo docker-compose.yml
(
echo version: '3.7'
echo.
echo services:
echo   mosquitto:
echo     image: eclipse-mosquitto
echo     ports:
echo       - "1883:1883"
echo       - "9001:9001"
echo     volumes:
echo       - %USERPROFILE%\iot\mosquitto:/mosquitto/config
echo     environment:
echo       - MQTT_USER=admin
echo       - MQTT_PASSWORD=admin
echo.
echo   nodered:
echo     image: nodered/node-red
echo     ports:
echo       - "1880:1880"
echo     environment:
echo       - NODE_RED_USERNAME=admin
echo       - NODE_RED_PASSWORD=admin
echo     volumes:
echo       - %USERPROFILE%\iot\nodered:/data
echo.
echo   grafana:
echo     image: grafana/grafana
echo     ports:
echo       - "3000:3000"
echo     environment:
echo       - GF_SECURITY_ADMIN_USER=admin
echo       - GF_SECURITY_ADMIN_PASSWORD=admin
echo     volumes:
echo       - %USERPROFILE%\iot\grafana:/var/lib/grafana
echo.
echo   influxdb:
echo     image: influxdb
echo     ports:
echo       - "8086:8086"
echo     environment:
echo       - INFLUXDB_ADMIN_USER=admin
echo       - INFLUXDB_ADMIN_PASSWORD=admin
echo     volumes:
echo       - %USERPROFILE%\iot\influxdb:/var/lib/influxdb
echo.
echo   mariadb:
echo     image: mariadb
echo     ports:
echo       - "3306:3306"
echo     environment:
echo       - MYSQL_ROOT_PASSWORD=admin
echo       - MYSQL_DATABASE=iot
echo       - MYSQL_USER=admin
echo       - MYSQL_PASSWORD=admin
echo     volumes:
echo       - %USERPROFILE%\iot\mariadb:/var/lib/mysql
echo.
echo   portainer:
echo     image: portainer/portainer-ce
echo     ports:
echo       - "9000:9000"
echo     volumes:
echo       - /var/run/docker.sock:/var/run/docker.sock
echo       - %USERPROFILE%\iot\portainer:/data
echo.
echo   adminer:
echo     image: adminer
echo     ports:
echo       - "8080:8080"
echo     environment:
echo       - ADMINER_DEFAULT_SERVER=mariadb
echo.
echo volumes:
echo   mosquitto:
echo   nodered:
echo   grafana:
echo   influxdb:
echo   mariadb:
echo   portainer:
echo   adminer:
) > %USERPROFILE%\iot\docker-compose.yml

REM Iniciar Docker Compose
cd %USERPROFILE%\iot
docker-compose up -d

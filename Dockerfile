FROM mcronce/steam-game-base:latest

RUN \
	echo "--- Installing Killing Floor 2 server; output is buffered by Docker, so this will take a while with no visibility." && \
	/app/steamcmd +login anonymous +force_install_dir /app/killing-floor-2 +app_update 232130 validate +exit && \
	mkdir -pv /app/killing-floor-2/KFGame/Cache

ADD LinuxServer-KFGame.ini /app/killing-floor-2/KFGame/Config/LinuxServer-KFGame.ini.example
ADD KFWeb.ini /app/killing-floor-2/KFGame/Config/KFWeb.ini.example

# Steam port
EXPOSE 20560/udp

# Query port - used to communicate with the master server
EXPOSE 27015/udp

# Game port - primary comms with players
EXPOSE 7777/udp

# Web Admin port
EXPOSE 8080/tcp

ENTRYPOINT ["/app/run"]


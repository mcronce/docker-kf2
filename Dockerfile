FROM ubuntu:xenial

RUN \
	apt-get -y update && \
	apt-get -y install curl lib32gcc1 && \
	apt-get clean && \
	find /var/lib/apt/lists -type f | xargs rm -vf

RUN useradd -m steam

WORKDIR /home/steam
USER steam

RUN \
	curl https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xzv && \
	./steamcmd.sh +exit

ADD kf2_functions.sh kf2_functions.sh 
ADD main main 

# Steam port
EXPOSE 20560/udp

# Query port - used to communicate with the master server
EXPOSE 27015/udp

# Game port - primary comms with players
EXPOSE 7777/udp

# Web Admin port
EXPOSE 8080/tcp

CMD ["/bin/bash", "main"]


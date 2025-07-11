FROM ubuntu:22.04

ENV PATH="/usr/games:${PATH}"

RUN apt-get update && \
    apt-get install -y minetest-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 30000/udp

CMD ["minetestserver", "--world", "/data/world"]


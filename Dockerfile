FROM alpine:3.11.6 AS base

RUN apk add --update-cache \
    unzip

# add the bootstrap file
COPY bootstrap.sh /tshock/bootstrap.sh

ENV TSHOCKVERSION=v4.4.0-pre11 \
    TSHOCKZIP=TShock4.4.0_Pre11_Terraria1.4.0.5.zip

# Download and unpack TShock
ADD https://github.com/Pryaxis/TShock/releases/download/$TSHOCKVERSION/$TSHOCKZIP /
RUN unzip "${TSHOCKZIP}" -d /tshock && \
    rm "${TSHOCKZIP}" && \
    chmod +x /tshock/TerrariaServer.exe && \
    # add executable perm to bootstrap
    chmod +x /tshock/bootstrap.sh

FROM mono:6.8.0.96-slim

LABEL maintainer="Ryan Sheehan <rsheehan@gmail.com>"

# documenting ports
EXPOSE 7777 7878

# env used in the bootstrap
ENV TERRARIA_USER="terraria"
ENV TERRARIA_ROOT="/home/${TERRARIA_USER}"
ENV TERRARIA_CONFIGPATH="${TERRARIA_ROOT}/Worlds" \
    TERRARIA_LOGPATH="${TERRARIA_ROOT}/logs" \
    TERRARIA_PLUGINPATH="${TERRARIA_ROOT}/plugins" \
    WORLD_FILENAME=""

# install nuget to grab tshock dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y \
    && apt-get install -y nuget \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# copy game files
COPY --from=base /tshock/ /tshock/

# init Terraria unprivileged user, no need to run as root
RUN useradd -m "${TERRARIA_USER}" \
    && mkdir -p "${TERRARIA_CONFIGPATH}" "${TERRARIA_LOGPATH}" "${TERRARIA_PLUGINPATH}" \
    && chown -R "${TERRARIA_USER}:${TERRARIA_USER}" /tshock \
    && chown -R "${TERRARIA_USER}:${TERRARIA_USER}" "${TERRARIA_ROOT}"

# Allow for external data
VOLUME ["${TERRARIA_CONFIGPATH}", "${TERRARIA_LOGPATH}", "${TERRARIA_PLUGINPATH}"]

# Set working directory to server
WORKDIR /tshock
USER ${TERRARIA_USER}

# run the bootstrap, which will copy the TShockAPI.dll before starting the server
ENTRYPOINT [ "/bin/bash", "bootstrap.sh" ]

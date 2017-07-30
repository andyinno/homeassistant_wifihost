FROM %%BASE_IMAGE%%

# Add env
ENV LANG C.UTF-8
ENV INITSYSTEM on

WORKDIR /usr/src/app
ENV DEVICE_TYPE=%%RESIN_MACHINE_NAME%%

RUN apk add --no-cache \
    dnsmasq \
    hostapd \
    iproute2 \
    iw \
    libdbus-1-dev \
    libexpat-dev \
    rfkill 

ENV NODE_VERSION 6.9.1

RUN curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-armv6l.tar.gz" && \
    echo "0b30184fe98bd22b859db7f4cbaa56ecc04f7f526313c8da42315d89fabe23b2  node-v$NODE_VERSION-linux-armv6l.tar.gz" | sha256sum -c - && \
    tar -xzf "node-v$NODE_VERSION-linux-armv6l.tar.gz" -C /usr/local --strip-components=1 && \
    rm "node-v$NODE_VERSION-linux-armv6l.tar.gz" && \
    npm config set unsafe-perm true -g --unsafe-perm && \
    rm -rf /tmp/*

ENV RESIN_WIFI_CONNECT_VERSION 2.0.7
RUN curl -SL "https://github.com/resin-io/resin-wifi-connect/archive/v$RESIN_WIFI_CONNECT_VERSION.tar.gz" \
    | tar xzC /usr/src/app/ && \
    mv resin-wifi-connect-$RESIN_WIFI_CONNECT_VERSION resin-wifi-connect && \
    cd resin-wifi-connect && \
    JOBS=MAX npm install --unsafe-perm --production && \
    npm cache clean && \
    ./node_modules/.bin/bower --allow-root install && \
    ./node_modules/.bin/bower --allow-root cache clean && \
    ./node_modules/.bin/coffee -c ./src

COPY . ./
CMD ["run.sh"]

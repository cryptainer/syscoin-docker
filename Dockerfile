FROM ubuntu:16.04

ARG syscoinVersion=3.0.5.0
ARG sentinelVersion=1.1.1
ARG _walletSourcePath=/usr/local/src/syscoind
ARG _sentinelSourcePath=/usr/local/src/sentinel
ARG _sentinelBin=/opt/sentinel/sentinel.sh
ARG _entryPointBin=/opt/docker-entrypoint.sh

ENV WALLET_CONF /etc/syscoin/syscoin.conf
ENV WALLET_DATA /data/
ENV SENTINEL_HOME ${_sentinelSourcePath}

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        libtool \
        autotools-dev \
        automake \
        pkg-config \
        libssl-dev \
        libevent-dev \
        bsdmainutils \
        libboost-all-dev \
        libminiupnpc-dev \
        libzmq3-dev \
        git \
        software-properties-common \
        python-virtualenv && \
    add-apt-repository ppa:bitcoin/bitcoin && \
        apt-get update && \
        apt-get install -y libdb4.8-dev libdb4.8++-dev && \
        apt-get purge -y python-software-properties

COPY opt /opt
COPY /docker-entrypoint.sh $_entryPointBin

RUN mkdir ${_walletSourcePath} && \
    cd ${_walletSourcePath} && \
    git clone https://github.com/syscoin/syscoin . && \
    git checkout ${syscoinVersion} && \
    ${_walletSourcePath}/autogen.sh && \
    ${_walletSourcePath}/configure && \
    make && \
    make install && \
    chmod +x $_entryPointBin && \
    ln -s $_entryPointBin /usr/local/bin/docker-entry && \
    mkdir -p /etc/syscoin

RUN mkdir ${_sentinelSourcePath} && \
    cd ${_sentinelSourcePath} && \
    git clone https://github.com/syscoin/sentinel . && \
    git checkout $sentinelVersion && \
    cd ${_sentinelSourcePath} && \
    virtualenv venv && \
    ./venv/bin/pip install -r requirements.txt && \
    echo "syscoin_conf=${WALLET_CONF}" >> sentinel.conf && \
    echo "SENTINEL_HOME=${SENTINEL_HOME}" > /tmp/crontab && \
    echo "* * * * * /usr/local/bin/sentinel >> /var/log/sentinel.log 2>&1" >> /tmp/crontab && \
    crontab /tmp/crontab && \
    rm -f /tmp/crontab && \
    chmod +x $_sentinelBin && \
    ln -s $_sentinelBin /usr/local/bin/sentinel && \
    ./venv/bin/py.test ./test 2>&1; exit 0

VOLUME /data

EXPOSE 8369

ENTRYPOINT ["docker-entry"]


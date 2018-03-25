#!/bin/bash

# Apply syscoin.conf configuration from environment variables
env | grep ^conf_ | sed -r 's/^conf_//g' > ${WALLET_CONF};

# If the container was restarted / the data directory is mounted from the host, there may be an old lock file
rm -f ${WALLET_DATA}/.lock

echo "Starting Syscoin Core."

if [ ${DEBUG} ]
then
    echo "syscoin.conf:"
    cat ${WALLET_CONF}
    echo "masternode.conf:"
    cat ${MASTERNODE_CONF}
else
    echo "Set DEBUG=1 to dump configs here."
fi

# Ensure cron is running, so sentinel is run periodically
cron;

exec syscoind -conf=${WALLET_CONF} -datadir=${WALLET_DATA}
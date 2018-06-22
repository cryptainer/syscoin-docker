#!/bin/bash

cd ${SENTINEL_HOME};

if [ ! -f .lock ]; then
    touch .lock
    ./venv/bin/python bin/sentinel.py;
    rm .lock;
fi
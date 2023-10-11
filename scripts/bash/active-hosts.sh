#!/bin/bash

subnet="10.0.30"
for host in {1..254}; do
    ping -c1 -w1 $subnet.$host > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        hostname=$(nslookup $subnet.$host | awk '/name = /{print $NF}')
        echo "Active host: $subnet.$host ($hostname)"
    fi
done
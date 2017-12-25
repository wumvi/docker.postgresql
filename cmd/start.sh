#!/bin/bash

source /lib-utils

# Run all
echo 'Run all'
/etc/init.d/postgrespro-std-10 start

# wait SIGTERM or SIGINT
echo 'wait SIGTERM or SIGINT'
wait_signal

# call stop
/etc/init.d/postgrespro-std-10 stop

# wait stop
wait_exit "postmaster"

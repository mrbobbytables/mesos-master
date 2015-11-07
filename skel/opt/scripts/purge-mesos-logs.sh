#!/bin/bash

mld=${MESOS_LOG_DIR:-/var/log/mesos}

cd "$mld"

(ls -t | grep 'log.INFO.*'|head -n 5;ls)|sort|uniq -u|grep 'log.INFO.*'|xargs --no-run-if-empty rm
(ls -t | grep 'log.ERROR.*'|head -n 5;ls)|sort|uniq -u|grep 'log.ERROR.*'|xargs --no-run-if-empty rm
(ls -t | grep 'log.WARNING.*'|head -n 5;ls)|sort|uniq -u|grep 'log.WARNING.*'|xargs --no-run-if-empty rm

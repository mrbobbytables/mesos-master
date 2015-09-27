#!/bin/bash
docker run -d --net=host \
-e ENVIRONMENT=production \
-e PARENT_HOST=$(hostname) \
-e MESOS_LOG_DIR=/var/log/mesos \
-e MESOS_LOGGING_LEVEL=WARNING \
-e MESOS_IP=10.10.0.11 \
-e MESOS_ZK=zk://10.10.0.11:2181,10.10.0.12:2181,10.10.0.13:2181/mesos \
-e MESOS_QUORUM=2 \
-e MESOS_CLUSTER=thegrid \
-e MESOS_WORK_DIR=/var/lib/mesos \
-p 5050:5050 \
-v /data/mesos:/var/lib/mesos:rw \
mesos-master


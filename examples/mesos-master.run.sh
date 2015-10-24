#!/bin/bash
docker run -d              \
--name master-01           \
--hostname master-01       \
-e ENVIRONMENT=production  \
-e PARENT_HOST=$(hostname) \
-e LIBPROCESS_PORT=9000    \
-e LIBPROCESS_ADVERTISE_PORT=9000      \
-e LIBPROCESS_ADVERTISE_IP=10.10.0.11  \
-e MESOS_ADVERTISE_PORT=5050           \
-e MESOS_ADVERTISE_IP=10.10.0.11       \
-e MESOS_LOG_DIR=/var/log/mesos        \
-e MESOS_LOGGING_LEVEL=WARNING         \
-e MESOS_ZK=zk://10.10.0.11:2181,10.10.0.12:2181,10.10.0.13:2181/mesos \
-e MESOS_QUORUM=2                 \
-e MESOS_CLUSTER=thegrid          \
-e MESOS_WORK_DIR=/var/lib/mesos  \
-p 10.10.0.11:5050:5050           \
-p 10.10.0.11:9000:9000           \
-v /data/mesos:/var/lib/mesos:rw  \
mesos-master


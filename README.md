# - Mesos Master -


An Ubuntu based Mesos Master container, packaged with Logstash-Forwarder and managed by Supervisord. All parameters are controlled through environment variables, with some settings auto-configured based on the environment.

##### Version Information:

* **Container Release:** 1.1.5
* **Mesos:** 0.26.0-0.2.145.ubuntu1404

##### Services include:
* **[Mesos Master](#mesos-master)** - Primary process that manages the collective offering of resources from the Mesos Slaves.
* **[Logrotate](#logrotate)** - A script and application that aid in pruning log files.
* **[Logstash-Forwarder](#logstash-forwarder)** - A lightweight log collector and shipper for use with [Logstash](https://www.elastic.co/products/logstash).
* **[Redpill](#redpill)** - A bash script and healthcheck for supervisord managed services. It is capable of running cleanup scripts that should be executed upon container termination.

---
---

### Index

* [Usage](#usage)
 * [Example Run Command](#example-run-command)
* [Modification and Anatomy of the Project](#modification-and-anatomy-of-the-project)
* [Important Environment Variables](#important-environment-variables)
* [Service Configuration](#service-configuration)
 * [Mesos-Master](#mesos)
 * [Logrotate](#logrotate)
 * [Logstash-Forwarder](#logstash-forwarder)
 * [Redpill](#redpill)
* [Troubleshooting](#troubleshooting)

---
---

### Usage

All mesos commands should be passed via environment variables (please see the [example run command](#example-run-command) below). For Mesos documentation, please see the configuration docs associated with the release here: [mesos@d3717e5](https://github.com/apache/mesos/tree/d3717e5c4d1bf4fca5c41cd7ea54fae489028faa/docs/configuration.md).

With the release of Mesos 0.24.0 the Mesos Master (and frameworks) no longer requires running with host networking enabled. This complicates deployments slightly, but overall adds significantly to the portability of the containers and frameworks.

In all forms of deployment, if the Mesos Master container is be accessible by other hosts or processes. There are collection of variables that must be set.

* `LIBPROCESS_IP` - The IP in which libprocess will bind to (defaults to `0.0.0.0`)

* `LIBPROCESS_PORT` - The port libprocess will use for communication (defaults to `9000`)

* `LIBPROCESS_ADVERTISE_IP` - If set, this will be the 'advertised' or `externalized` ip used for libprocess communication. Relevant when running an application that uses libprocess within a container, and should be set to the host IP in which you wish to use for Mesos communication.

* `LIBPROCESS_ADVERTISE_PORT` - If set, this will be the 'advertised' or 'externalized' port used for libprocess communication. Relevant when running an application that uses libprocess within a container, and should be set to the host port you wish to use for Mesos communication.

* `MESOS_ADVERTISE_IP` - If set, this will be the 'advertised' or 'externalized' ip used to reach and communicate with the Mesos Master.

* `MESOS_ADVERTISE_PORT` - If set, this will be the 'advertised' or 'externalized' port used for communication with the Mesos Master.

If deploying **WITH** host networking, the `*_ADVERTISE_*` variables may be omitted.

In a local deployment, other than the above the only other variable that must be set is `MESOS_ZK`.

In a production deployment with high availability, the Master container should be executed with several other variables defined including `ENVIRONMENT`, `MESOS_WORK_DIR`, and`MESOS_QUORUM`.

* `ENVIRONMENT` - when set to `production` or `development` it will enable all services including: `mesos-master`, `logstash-forwarder`, and `redpill`.

* `MESOS_ZK` - The zookeeper URL used by Mesos for leader election e.g. `zk://10.10.0.11:2181,10.10.0.12:2181,10.10.0.13:2181/mesos`.

* `MESOS_QUORUM` - The quorum size of Mesos Registry. It should be equal to the majority of your Mesos Masters. At a bare minimum it should be (# of Mesos Masters/2)+1.

* `MESOS_WORK_DIR` - The location in which the Mesos registry is stored. A volume should be mounted to the `MESOS_WORK_DIR` to maintain state across redeployments.

---

### Example Run Command
```bash
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

```

---
---

### Modification and Anatomy of the Project

**File Structure**
The directory `skel` in the project root maps to the root of the file system once the container is built. Files and folders placed there will map to their corresponding location within the container.

**Init**
The init script (`./init.sh`) found at the root of the directory is the entry process for the container. It's role is to simply set specific environment variables and modify any subsequently required configuration files.

**Supervisord**
All supervisord configs can be found in `/etc/supervisor/conf.d/`. Services by default will redirect their stdout to `/dev/fd/1` and stderr to `/dev/fd/2` allowing for service's console output to be displayed. Most applications can log to both stdout and their respectively specified log file.

In some cases (such as with zookeeper), it is possible to specify different logging levels and formats for each location.

**Logstash-Forwarder**
The Logstash-Forwarder binary and default configuration file can be found in `/skel/opt/logstash-forwarder`. It is ideal to bake the Logstash Server certificate into the base container at this location. If the certificate is called `logstash-forwarder.crt`, the default supplied Logstash-Forwarder config should not need to be modified, and the server setting may be passed through the `SERVICE_LOGSTASH_FORWARDER_ADDRESS` environment variable.

In practice, the supplied Logstash-Forwarder config should be used as an example to produce one tailored to each deployment.

---
---

### Important Environment Variables

Below is the minimum list of variables to be aware of when deploying the Mesos Master container.

#### Defaults

| **Variable**                      | **Default**                                 |
|-----------------------------------|---------------------------------------------|
| `ENVIRONMENT_INIT`                |                                             |
| `APP_NAME`                        | `mesos-master`                              |
| `ENVIRONMENT`                     | `local`                                     |
| `PARENT_HOST`                     | `unknown`                                   |
| `LIBPROCESS_IP`                   | `0.0.0.0`                                   |
| `LIBPROCESS_PORT`                 | `9000`                                      |
| `LIBPROCESS_ADVERTISE_IP`         |                                             |
| `LIBPROCESS_ADVERTISE_PORT`       |                                             |
| `MESOS_ADVERTISE_IP`              |                                             |
| `MESOS_ADVERTISE_PORT`            |                                             |
| `MESOS_LOG_DIR`                   | `/var/log/mesos`                            |
| `MESOS_QUORUM`                    |                                             |
| `MESOS_WORK_DIR`                  |                                             |
| `MESOS_ZK`                        |                                             |
| `GLOG_max_log_size`               |                                             |
| `SERVICE_LOGROTATE`               |                                             |
| `SERVICE_LOGROTATE_INTERVAL`      | `3600` (set in script by default)           |
| `SERVICE_LOGROTATE_SCRIPT`        | `/opt/scripts/purge-mesos-logs.sh`          |
| `SERVICE_LOGSTASH_FORWARDER`      |                                             |
| `SERVICE_LOGSTASH_FORWARDER_CONF` | `/opt/logstash-forwarder/mesos-master.conf` |
| `SERVICE_REDPILL`                 |                                             |
| `SERVICE_REDPILL_MONITOR`         | `mesos`                                     |

##### Description

* `ENVIRONMENT_INIT` - If set, and the file path is valid. This will be sourced and executed before **ANYTHING** else. Useful if supplying an environment file or need to query a service such as consul to populate other variables.

* `APP_NAME` - A brief description of the container. If Logstash-Forwarder is enabled, this will populate the `app_name` field in the Logstash-Forwarder configuration file.

* `ENVIRONMENT` - Sets defaults for several other variables based on the current running environment. Please see the [environment](#environment) section for further information. If logstash-forwarder is enabled, this value will populate the `environment` field in the logstash-forwarder configuration file.

* `PARENT_HOST` - The name of the parent host. If Logstash-Forwarder is enabled, this will populate the `parent_host` field in the Logstash-Forwarder configuration file.

* `LIBPROCESS_IP` - The IP in which libprocess will bind to (defaults to `0.0.0.0`)

* `LIBPROCESS_PORT` - The port libprocess will use for communication (defaults to `9000`)

* `LIBPROCESS_ADVERTISE_IP` - If set, this will be the 'advertised' or `externalized` ip used for libprocess communication. Relevant when running an application that uses libprocess within a container, and should be set to the host IP in which you wish to use for Mesos communication.

* `LIBPROCESS_ADVERTISE_PORT` - If set, this will be the 'advertised' or 'externalized' port used for libprocess communication. Relevant when running an application that uses libprocess within a container, and should be set to the host port you wish to use for Mesos communication.

* `MESOS_ADVERTISE_IP` - If set, this will be the 'advertised' or 'externalized' ip used to reach and communicate with the Mesos Master.

* `MESOS_ADVERTISE_PORT` - If set, this will be the 'advertised' or 'externalized' port used for communication with the Mesos Master.

* `MESOS_LOG_DIR` - The path to the directory in which Mesos stores its logs.

* `MESOS_QUORUM` - The quorum size of Mesos Registry. It should be equal to the majority of your Mesos Masters. At a bare minimum it should be (# of Mesos Masters/2)+1.

* `MESOS_WORK_DIR` - The location in which the Mesos registry is stored. A volume should be mounted to the `MESOS_WORK_DIR` to maintain state across redeployments.

* `MESOS_ZK` - The zookeeper URL used by Mesos for leader election e.g. `zk://10.10.0.11:2181,10.10.0.12:2181,10.10.0.13:2181/mesos`.

* `GLOG_max_file_size` - The size in Megabytes that the mesos log file(s) will be allowed to grow to before rotation.

* `SERVICE_LOGROTATE` - Enables or disabled the Logrotate service. This will be set automatically depending on the environment. (**Options:** `enabled` or `disabled`)

* `SERVICE_LOGROTATE_INTERVAL` - The time in seconds between runs of logrotate or the logrotate script. The default (3600 or 1 hour) is set by default in the logrotate script automatically.

* `SERVICE_LOGROTATE_SCRIPT` - The path to the script that should be executed instead of logrotate itself to clean up logs.

* `SERVICE_LOGSTASH_FORWARDER` - Enables or disables the Logstash-Forwarder service. Set automatically depending on the `ENVIRONMENT`. See the Environment section below.  (**Options:** `enabled` or `disabled`)

* `SERVICE_LOGSTASH_FORWARDER_CONF` - The path to the logstash-forwarder configuration.

* `SERVICE_REDPILL` - Enables or disables the Redpill service. Set automatically depending on the `ENVIRONMENT`. See the Environment section below.  (**Options:** `enabled` or `disabled`)

* `SERVICE_REDPILL_MONITOR` - The name of the supervisord service(s) that the Redpill service check script should monitor.


---

**Environment**

* `local` (default)

| **Variable**                 | **Default**                |
|------------------------------|----------------------------|
| `GLOG_max_log_size`          | `10`                       |
| `SERVICE_LOGROATE`           | `enabled`                  |
| `SERVICE_LOGSTASH_FORWARDER` | `disabled`                 |
| `SERVICE_REDPILL`            | `enabled`                  |
| `MESOS_WORK_DIR`             | `/var/lib/mesos`           |


* `prod`|`production`|`dev`|`development`

| **Variable**                 | **Default** |
|------------------------------|-------------|
| `GLOG_max_log_size`          | `10`        |
| `SERVICE_LOGROATE`           | `enabled`   |
| `SERVICE_LOGSTASH_FORWARDER` | `enabled`   |
| `SERVICE_REDPILL`            | `enabled`   |


* `debug`

| **Variable**                 | **Default** |
|------------------------------|-------------|
| `SERVICE_LOGROATE`           | `disabled`  |
| `SERVICE_LOGSTASH_FORWARDER` | `disabled`  |
| `SERVICE_REDPILL`            | `disabled`  |


---
---

### Service Configuration

---

### Mesos-Master


As stated in the [Usage](#usage) section, Mesos-slave configuration information can be found in the github docs releated to the Mesos Release: [mesos@d3717e5](https://github.com/apache/mesos/tree/d3717e5c4d1bf4fca5c41cd7ea54fae489028faa/docs/configuration.md).


The actual mesos start command is passed to supervisor via the `SERVICE_MESOS_CMD` environment variable, and defaults to `mesos-master`. It can be overridden by specifying the `SERVICE_MESOS_CMD` at run time.

#### Mesos-Master Environment Variables

##### Defaults

| **Variable**                | **Default**      |
|-----------------------------|------------------|
| `LIBPROCESS_IP`             | `0.0.0.0`        |
| `LIBPROCESS_PORT`           | `9000`           |
| `LIBPROCESS_ADVERTISE_IP`   |                  |
| `LIBPROCESS_ADVERTISE_PORT` |                  |
| `MESOS_ADVERTISE_IP`        |                  |
| `MESOS_ADVERTISE_PORT`      |                  |
| `MESOS_LOG_DIR`             | `/var/log/mesos` |
| `MESOS_QUORUM`              |                  |
| `MESOS_WORK_DIR`            |                  |
| `MESOS_ZK`                  |                  |

##### Description

* `LIBPROCESS_IP` - The IP in which libprocess will bind to (defaults to `0.0.0.0`)

* `LIBPROCESS_PORT` - The port libprocess will use for communication (defaults to `9000`)

* `LIBPROCESS_ADVERTISE_IP` - If set, this will be the 'advertised' or `externalized` ip used for libprocess communication. Relevant when running an application that uses libprocess within a container, and should be set to the host IP in which you wish to use for Mesos communication.

* `LIBPROCESS_ADVERTISE_PORT` - If set, this will be the 'advertised' or 'externalized' port used for libprocess communication. Relevant when running an application that uses libprocess within a container, and should be set to the host port you wish to use for Mesos communication.

* `MESOS_ADVERTISE_IP` - If set, this will be the 'advertised' or 'externalized' ip used to reach and communicate with the Mesos Master.

* `MESOS_ADVERTISE_PORT` - If set, this will be the 'advertised' or 'externalized' port used for communication with the Mesos Master.

* `MESOS_LOG_DIR` - The path to the directory in which Mesos stores its logs.

* `MESOS_QUORUM` - The quorum size of Mesos Registry. It should be equal to the majority of your Mesos Masters. At a bare minimum it should be (# of Mesos Masters/2)+1.

* `MESOS_WORK_DIR` - The location in which the Mesos registry is stored. A volume should be mounted to the `MESOS_WORK_DIR` to maintain state across redeployments.

* `MESOS_ZK` - The zookeeper URL used by Mesos for leader election e.g. `zk://10.10.0.11:2181,10.10.0.12:2181,10.10.0.13:2181/mesos`.

* `SERVICE_MESOS_CMD` -  The command that is passed to supervisor. If overriding, must be an escaped python string expression. Please see the [Supervisord Command Documentation](http://supervisord.org/configuration.html#program-x-section-settings) for further information. 


---

### Logrotate

The logrotate script is a small simple script that will either call and execute logrotate on a given interval; or execute a supplied script. This is useful for applications that do not perform their own log cleanup.

#### Logrotate Environment Variables

##### Defaults

| **Variable**                 | **Default**                        |
|------------------------------|------------------------------------|
| `SERVICE_LOGROTATE`          |                                    |
| `SERVICE_LOGROTATE_INTERVAL` | `3600`                             |
| `SERVICE_LOGROTATE_CONFIG`   |                                    |
| `SERVICE_LOGROTATE_SCRIPT`   | `/opt/scripts/purge-mesos-logs.sh` |
| `SERVICE_LOGROTATE_FORCE`    |                                    |
| `SERVICE_LOGROTATE_VERBOSE`  |                                    |
| `SERVICE_LOGROTATE_DEBUG`    |                                    |
| `SERVICE_LOGROTATE_CMD`      | `/opt/script/logrotate.sh <flags>` |

##### Description

* `SERVICE_LOGROTATE` - Enables or disables the Logrotate service. Set automatically depending on the `ENVIRONMENT`. See the Environment section.  (**Options:** `enabled` or `disabled`)

* `SERVICE_LOGROTATE_INTERVAL` - The time in seconds between run of either the logrotate command or the provided logrotate script. Default is set to `3600` or 1 hour in the script itself.

* `SERVICE_LOGROTATE_CONFIG` - The path to the logrotate config file. If neither config or script is provided, it will default to `/etc/logrotate.conf`.

* `SERVICE_LOGROTATE_SCRIPT` - A script that should be executed on the provided interval. Useful to do cleanup of logs for applications that already handle rotation, or if additional processing is required.

* `SERVICE_LOGROTATE_FORCE` - If present, passes the 'force' command to logrotate. Will be ignored if a script is provided.

* `SERVICE_LOGROTATE_VERBOSE` - If present, passes the 'verbose' command to logrotate. Will be ignored if a script is provided.

* `SERVICE_LOGROTATE_DEBUG` - If present, passed the 'debug' command to logrotate. Will be ignored if a script is provided.

* `SERVICE_LOGROTATE_CMD` - The command that is passed to supervisor. If overriding, must be an escaped python string expression. Please see the [Supervisord Command Documentation](http://supervisord.org/configuration.html#program-x-section-settings) for further information.


##### Logrotate Script Help Text
```
root@ec58ca7459cb:/opt/scripts# ./logrotate.sh --help
logrotate.sh - Small wrapper script for logrotate.
-i | --interval     The interval in seconds that logrotate should run.
-c | --config       Path to the logrotate config.
-s | --script       A script to be executed in place of logrotate.
-f | --force        Forces log rotation.
-v | --verbose      Display verbose output.
-d | --debug        Enable debugging, and implies verbose output. No state file changes.
-h | --help         This usage text.
```

##### Supplied Cleanup Script

The below cleanup script will remove all but the latest 5 rotated logs.
```bash
#!/bin/bash

mld=${MESOS_LOG_DIR:-/var/log/mesos}

cd "$mld"

(ls -t | grep 'log.INFO.*'|head -n 5;ls)|sort|uniq -u|grep 'log.INFO.*'|xargs --no-run-if-empty rm
(ls -t | grep 'log.ERROR.*'|head -n 5;ls)|sort|uniq -u|grep 'log.ERROR.*'|xargs --no-run-if-empty rm
(ls -t | grep 'log.WARNING.*'|head -n 5;ls)|sort|uniq -u|grep 'log.WARNING.*'|xargs --no-run-if-empty rm
```


---


### Logstash-Forwarder

Logstash-Forwarder is a lightweight application that collects and forwards logs to a logstash server endpoint for further processing. For more information see the [Logstash-Forwarder](https://github.com/elastic/logstash-forwarder) project.


#### Logstash-Forwarder Environment Variables

##### Defaults

| **Variable**                         | **Default**                                                                            |
|--------------------------------------|----------------------------------------------------------------------------------------|
| `SERVICE_LOGSTASH_FORWARDER`         |                                                                                        |
| `SERVICE_LOGSTASH_FORWARDER_CONF`    | `/opt/logstash-forwarder/mesos-master.conf`                                            |
| `SERVICE_LOGSTASH_FORWARDER_ADDRESS` |                                                                                        |
| `SERVICE_LOGSTASH_FORWARDER_CERT`    |                                                                                        |
| `SERVICE_LOGSTASH_FORWARDER_CMD`     | `/opt/logstash-forwarder/logstash-fowarder -config="${SERVICE_LOGSTASH_FOWARDER_CONF}"` |


##### Description

* `SERVICE_LOGSTASH_FORWARDER` - Enables or disables the Logstash-Forwarder service. Set automatically depending on the `ENVIRONMENT`. See the Environment section.  (**Options:** `enabled` or `disabled`)

* `SERVICE_LOGSTASH_FORWARDER_CONF` - The path to the logstash-forwarder configuration.

* `SERVICE_LOGSTASH_FORWARDER_ADDRESS` - The address of the Logstash server.

* `SERVICE_LOGSTASH_FORWARDER_CERT` - The path to the Logstash-Forwarder server certificate.

* `SERVICE_LOGSTASH_FORWARDER_CMD` - The command that is passed to supervisor. If overriding, must be an escaped python string expression. Please see the [Supervisord Command Documentation](http://supervisord.org/configuration.html#program-x-section-settings) for further information.


---


### Redpill

Redpill is a small script that performs status checks on services managed through supervisor. In the event of a failed service (FATAL) Redpill optionally runs a cleanup script and then terminates the parent supervisor process.

#### Redpill Environment Variables

##### Defaults

| **Variable**               | **Default** |
|----------------------------|-------------|
| `SERVICE_REDPILL`          |             |
| `SERVICE_REDPILL_MONITOR`  | `mesos`     |
| `SERVICE_REDPILL_INTERVAL` |             |
| `SERVICE_REDPILL_CLEANUP`  |             |
| `SERVICE_REDPILL_CMD`      |             |


##### Description

* `SERVICE_REDPILL` - Enables or disables the Redpill service. Set automatically depending on the `ENVIRONMENT`. See the Environment section.  (**Options:** `enabled` or `disabled`)

* `SERVICE_REDPILL_MONITOR` - The name of the supervisord service(s) that the Redpill service check script should monitor. 

* `SERVICE_REDPILL_INTERVAL` - The interval in which Redpill polls supervisor for status checks. (Default for the script is 30 seconds)

* `SERVICE_REDPILL_CLEANUP` - The path to the script that will be executed upon container termination.

* `SERVICE_REDPILL_CMD` - The command that is passed to supervisor. It is dynamically built from the other redpill variables. If overriding, must be an escaped python string expression. Please see the [Supervisord Command Documentation](http://supervisord.org/configuration.html#program-x-section-settings) for further information.


##### Redpill Script Help Text

```
root@c90c98ae31e1:/# /opt/scripts/redpill.sh --help
Redpill - Supervisor status monitor. Terminates the supervisor process if any specified service enters a FATAL state.

-c | --cleanup    Optional path to cleanup script that should be executed upon exit.
-h | --help       This help text.
-i | --interval   Optional interval at which the service check is performed in seconds. (Default: 30)
-s | --service    A comma delimited list of the supervisor service names that should be monitored.
```

---
---

### Troubleshooting

In the event of an issue, the `ENVIRONMENT` variable can be set to `debug`.  This will stop the container from shipping logs and prevent it from terminating if one of the services enters a failed state.

For mesos itself, the `MESOS_LOGGING_LEVEL` variable can be set to `INFO` or `WARNING` to further diagnose the problem.

If further information is needed; logging may be controlled directly by configuring [glog](https://github.com/google/glog) loggig library used by Mesos. For reference; please see the table below:

**Note:** not all of the glog settings are overridable. Mesos does dictate some of them. Main ones of note are `GLOG_v` to increase log verbosity, and `GLOG_max_log_size` if log growth and rotation must be tuned.

| **Environment Variable Name**    | **Type** | **Default** | **Description**                                                                                                                                                                                             |
|----------------------------------|----------|-------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `GLOG_logtostderr`               | `bool`   | `FALSE`     | Log messages go to stderr instead of logfiles.                                                                                                                                                              |
| `GLOG_alsologtostderr`           | `bool`   | `FALSE`     | Log messages go to stderr in addition to logfiles.                                                                                                                                                         |
| `GLOG_colorlogtostderr`          | `bool`   | `FALSE`     | Color messages logged to stderr (if supported by terminal).                                                                                                                                                 |
| `GLOG_stderrthreshold`           | `int`    | `2`         | Log messages at or above this level are copied to stderr in addition to logfiles.  This flag obsoletes –alsologtostderr.                                                                                    |
| `GLOG_alsologtomail`             | `string` |             | Log messages go to these email addresses in addition to logfiles.                                                                                                                                           |
| `GLOG_logmaillevel`              | `int`    | `999`       | Email log messages logged at this level or higher (0 means email all; 3 means email FATAL only ...)                                                                                                         |
| `GLOG_logmailer`                 | `string` | `/bin/mail` | Mailer used to send logging email.                                                                                                                                                                          |
| `GLOG_drop_log_memory`           | `bool`   | `TRUE`      | Drop in-memory buffers of log contents. Logs can grow very quickly and they are rarely read before they need to be evicted from memory. Instead, drop them from memory as soon as they are flushed to disk. |
| `GLOG_log_prefix`                | `bool`   | `TRUE`      | Prepend the log prefix to the start of each log line.                                                                                                                                                       |
| `GLOG_minloglevel`               | `int`    | `0`         | Messages logged at a lower level than this don't actually get logged anywhere.                                                                                                                              |
| `GLOG_logbuflevel`               | `int`    | `0`         | Buffer log messages logged at this level or lower (-1 means don't buffer; 0 means buffer INFO only...).                                                                                                     |
| `GLOG_logbufsecs`                | `int`    | `30`        | Buffer log messages for at most this many seconds.                                                                                                                                                          |
| `GLOG_logfile_mode`              | `int`    | `0644`      | Log file mode/permissions.                                                                                                                                                                                  |
| `GLOG_log_dir`                   | `string` |             | If specified, logfiles are written into this directory instead of the default logging directory.                                                                                                            |
| `GLOG_log_link`                  | `string` |             | Put additional links to the log files in this directory.                                                                                                                                                    |
| `GLOG_max_log_size`              | `int`    | `1800`      | Approx. maximum log file size (in MB). A value of 0 will be silently overridden to 1.                                                                                                                       |
| `GLOG_stop_logging_if_full_disk` | `bool`   | `FALSE`     | Stop attempting to log to disk if the disk is full.                                                                                                                                                         |
| `GLOG_log_backtrace_at`          | `string` |             | Emit a backtrace when logging at file:linenum.                                                                                                                                                              |
| `GLOG_v`                         | `int`    | `0`         | Show all VLOG(m) messages for m less or equal the value of this flag.                                                                                                                                       |


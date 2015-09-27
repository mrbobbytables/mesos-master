#!/bin/bash

########## Mesos Master ##########
# Init Script for Mesos Master
########## Mesos Master ##########

source /opt/scripts/container_functions.lib.sh

init_vars() {

  if [[ $ENVIRONMENT_INIT && -f $ENVIRONMENT_INIT ]]; then
      source "$ENVIRONMENT_INIT"
  fi 

  if [[ ! $PARENT_HOST && $HOST ]]; then
    export PARENT_HOST="$HOST"
  fi

  export APP_NAME=${APP_NAME:-mesos-master}
  export ENVIRONMENT=${ENVIRONMENT:-local} 
  export PARENT_HOST=${PARENT_HOST:-unknown}

  # Default logging level for Mesos is INFO. No need to set.
  export MESOS_LOG_DIR==${MESOS_LOG_DIR:-/var/log/mesos}

  export SERVICE_LOGSTASH_FORWARDER_CONF=${SERVICE_LOGSTASH_FORWARDER_CONF:-/opt/logstash-forwarder/mesos-master.conf}
  export SERVICE_REDPILL_MONITOR=${SERVICE_REDPILL_MONITOR:-mesos}

  export SERVICE_MESOS_CMD=${SERVICE_MESOS_CMD:-mesos-master}

  case "${ENVIRONMENT,,}" in
    prod|production|dev|development)
      export SERVICE_LOGSTASH_FORWARDER=${SERVICE_LOGSTASH_FORWARDER:-enabled}
      export SERVICE_REDPILL=${SERVICE_REDPILL:-enabled}
      ;;
    debug)
      export SERVICE_LOGSTASH_FORWARDER=${SERVICE_LOGSTASH_FORWARDER:-disabled}
      export SERVICE_REDPILL=${SERVICE_REDPILL:-disabled}
      ;;
   local|*)
      local local_ip="$(ip addr show eth0 | grep -m 1 -P -o '(?<=inet )[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')"
      export MESOS_HOSTNAME=${MESOS_HOSTNAME:-"$local_ip"}
      export SERVICE_LOGSTASH_FORWARDER=${SERVICE_LOGSTASH_FORWARDER:-disabled}
      export SERVICE_REDPILL=${SERVICE_REDPILL:-enabled}
      export MESOS_WORK_DIR=${MESOS_WORK_DIR:-/var/lib/mesos}
      ;;
  esac
 }

main() {

  init_vars
  
  echo "[$(date)][App-Name] $APP_NAME"
  echo "[$(date)][Environment] $ENVIRONMENT"

  __config_service_logstash_forwarder
  __config_service_redpill

  echo "[$(date)][Mesos][Start-Command] $SERVICE_MESOS_CMD"

  exec supervisord -n -c /etc/supervisor/supervisord.conf

}

main "$@"

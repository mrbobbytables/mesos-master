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
  export MESOS_LOG_DIR=${MESOS_LOG_DIR:-/var/log/mesos}

  export SERVICE_CONSUL_TEMPLATE=${SERVICE_CONSUL_TEMPLATE:-disabled}
  export SERVICE_LOGROTATE_SCRIPT=${SERVICE_LOGROTATE_SCRIPT:-/opt/scripts/purge-mesos-logs.sh}
  export SERVICE_LOGSTASH_FORWARDER_CONF=${SERVICE_LOGSTASH_FORWARDER_CONF:-/opt/logstash-forwarder/mesos-master.conf}
  export SERVICE_REDPILL_MONITOR=${SERVICE_REDPILL_MONITOR:-mesos}

  export SERVICE_MESOS_CMD=${SERVICE_MESOS_CMD:-mesos-master}

  case "${ENVIRONMENT,,}" in
    prod|production|dev|development)
      export GLOG_max_log_size=${GLOG_max_log_size:-10}
      export SERVICE_LOGROTATE=${SERVICE_LOGROTATE:-enabled}
      export SERVICE_LOGSTASH_FORWARDER=${SERVICE_LOGSTASH_FORWARDER:-enabled}
      export SERVICE_REDPILL=${SERVICE_REDPILL:-enabled}
      ;;
    debug)
      export SERVICE_LOGROTATE=${SERVICE_LOGROTATE:-disabled}
      export SERVICE_LOGSTASH_FORWARDER=${SERVICE_LOGSTASH_FORWARDER:-disabled}
      export SERVICE_REDPILL=${SERVICE_REDPILL:-disabled}
      if [[ "$SERVICE_CONSUL_TEMPLATE" == "enabled" ]]; then
        export CONSUL_TEMPLATE_LOG_LEVEL=${CONSUL_TEMPLATE_LOG_LEVEL:-debug}
      fi
      ;;
   local|*)
      export GLOG_max_log_size=${GLOG_max_log_size:-10}
      export SERVICE_LOGROTATE=${SERVICE_LOGROTATE:-enabled}
      export SERVICE_LOGSTASH_FORWARDER=${SERVICE_LOGSTASH_FORWARDER:-disabled}
      export SERVICE_REDPILL=${SERVICE_REDPILL:-enabled}
      export MESOS_WORK_DIR=${MESOS_WORK_DIR:-/var/lib/mesos}
      ;;
  esac

  if [[ "$SERVICE_CONSUL_TEMPLATE" == "enabled" ]]; then
    export SERVICE_RSYSLOG=${SERVICE_RSYSLOG:-enabled}
  fi
 }

main() {

  init_vars
  
  echo "[$(date)][App-Name] $APP_NAME"
  echo "[$(date)][Environment] $ENVIRONMENT"

  __config_service_consul_template
  __config_service_logrotate
  __config_service_logstash_forwarder
  __config_service_redpill
  __config_service_rsyslog

  echo "[$(date)][Mesos][Start-Command] $SERVICE_MESOS_CMD"

  exec supervisord -n -c /etc/supervisor/supervisord.conf

}

main "$@"

################################################################################
# mesos-master:1.0.1
# Date: 10/7/2015
# Mesos Version: 0.23.0-1.0
#
# Description:
# Mesos Master container. Mesos Version is tied to mesos-base container.
################################################################################

FROM mrbobbytables/mesos-base:1.0.1
MAINTAINER Bob Killen / killen.bob@gmail.com / @mrbobbytables

COPY ./skel /

RUN chmod +x init.sh            \
 && chown -R logstash-forwarder:logstash-forwarder /opt/logstash-forwarder

EXPOSE 5050

CMD ["./init.sh"]

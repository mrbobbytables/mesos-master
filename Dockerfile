################################################################################
# mesos-master: 1.1.5
# Date: 12/21/2015
# Mesos Version: 0.26.0-0.2.145.ubuntu1404
#
# Description:
# Mesos Master container. Mesos Version is tied to mesos-base container.
################################################################################

FROM mrbobbytables/mesos-base:1.1.4

MAINTAINER Bob Killen / killen.bob@gmail.com / @mrbobbytables

COPY ./skel /

RUN chmod +x init.sh  \
 && chown -R logstash-forwarder:logstash-forwarder /opt/logstash-forwarder

EXPOSE 5050

CMD ["./init.sh"]

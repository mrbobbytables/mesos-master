################################################################################
# mesos-master: 1.1.0
# Date: 10/20/2015
# Mesos Version: 0.24.1-0.2.35.ubuntu1404
#
# Description:
# Mesos Master container. Mesos Version is tied to mesos-base container.
################################################################################

FROM mrbobbytables/mesos-base:1.1.0

MAINTAINER Bob Killen / killen.bob@gmail.com / @mrbobbytables

COPY ./skel /

RUN chmod +x init.sh            \
 && chown -R logstash-forwarder:logstash-forwarder /opt/logstash-forwarder

EXPOSE 5050

CMD ["./init.sh"]

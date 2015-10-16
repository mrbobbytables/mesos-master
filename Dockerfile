################################################################################
# mesos-master:1.0.2
# Date: 10/16/2015
# Mesos Version: 0.23.1-0.2.61.ubuntu1404
#
# Description:
# Mesos Master container. Mesos Version is tied to mesos-base container.
################################################################################

FROM mrbobbytables/mesos-base:1.0.2
MAINTAINER Bob Killen / killen.bob@gmail.com / @mrbobbytables

COPY ./skel /

RUN chmod +x init.sh            \
 && chown -R logstash-forwarder:logstash-forwarder /opt/logstash-forwarder

EXPOSE 5050

CMD ["./init.sh"]

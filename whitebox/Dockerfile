FROM alpine:latest
RUN apk update
RUN apk add --upgrade busybox
RUN apk add openvswitch tcpdump nano iproute2 ethtool bash util-linux wget
WORKDIR /bin

COPY boot.sh /bin/boot.sh

WORKDIR /

ENV PS1="[sdnm:whitebox \u@\h]# "

LABEL br.rnp.label.name="whiteBox"\
      br.rnp.label.description="SDN Whitebox Switch"\
      br.rnp.label.vendor="National Network for Education and Research - RNP"\
      br.rnp.label.contact="fernando.farias@rnp.br"\
      br.rnp.label.application="CNetLab"\
      br.rnp.label.version="0.1"\
      br.rnp.label.license="Apache2"

VOLUME /lib/modules /lib/modules

CMD ["/bin/sh","/bin/boot.sh"]
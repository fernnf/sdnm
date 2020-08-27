FROM alpine:latest
RUN apk update
RUN apk add --upgrade busybox
RUN apk add openvswitch tcpdump nano iproute2 ethtool bash util-linux wget
WORKDIR /bin

COPY boot.sh /bin/boot.sh

WORKDIR /

ENV PS1="[sdnm:whitebox \u@\h]# "

LABEL br.ufpa.label.name="WhiteBox"\
      br.ufpa.label.description="SDN Whitebox Switch"\
      br.ufpa.label.vendor="National Network for Education and Research - RNP"\
      br.ufpa.label.contact="fernando.farias@rnp.br"\
      br.ufpa.label.application="CNetLab"\
      br.ufpa.label.version="0.1"\
      br.ufpa.label.license="Apache2"

VOLUME /lib/modules /lib/modules

CMD ["/bin/sh","/bin/boot.sh"]
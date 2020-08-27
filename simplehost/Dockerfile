FROM alpine:latest
RUN apk update
RUN apk add iperf3 tcpdump iputils nano ethtool iproute2 net-tools bash

ENV TERM=vt100
ENV PS1="[sdnm:host \u@\h]# "

LABEL br.ufpa.label.name="Host"\
      br.ufpa.label.description="Simple Host Computer"\
      br.ufpa.label.vendor="National Network for Education and Research - RNP"\
      br.ufpa.label.contact="fernando.farias@rnp.br"\
      br.ufpa.label.application="CNetLab"\
      br.ufpa.label.version="0.1"\
      br.ufpa.label.license="Apache2"

CMD [ "/bin/ash" ]

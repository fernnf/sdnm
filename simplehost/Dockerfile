FROM debian:buster-slim
RUN apt-get update
RUN apt-get install -y iperf3 tcpdump iputils-ping net-tools nano ethtool iproute2  bash

ENV TERM=vt100
ENV PS1="[sdnm:host \u@\h]# "

LABEL br.rnp.label.name="host"\
      br.rnp.label.description="Simple Host Computer"\
      br.rnp.label.vendor="National Network for Education and Research - RNP"\
      br.rnp.label.contact="fernando.farias@rnp.br"\
      br.rnp.label.application="CNetLab"\
      br.rnp.label.version="0.1"\
      br.rnp.label.license="Apache2"

CMD [ "/bin/bash" ]

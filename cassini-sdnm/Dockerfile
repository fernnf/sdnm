FROM sdnm/cassini-odtn:latest

WORKDIR /root

RUN git clone https://github.com/fernnf/cassini-dataplane.git

ENV PYTHONPATH=/root/cassini-dataplane/

RUN chmod +x /root/cassini-dataplane/docker/sdnml/init-service.sh

CMD ["/root/cassini-dataplane/docker/sdnml/init-service.sh"]
FROM debian:bullseye

WORKDIR /root

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y software-properties-common build-essential openssl libssl-dev libpcre3 libpcre3-dev git make \
    cmake bison flex pkg-config graphviz doxygen valgrind zlib1g zlib1g-dev libev-dev libavl-dev libprotobuf-c-dev \
    protobuf-c-compiler swig python-dev lua5.2 vim net-tools debhelper apt-utils python3-dev python3-pip man \
    libcurl4-openssl-dev lib32ncurses5-dev git


RUN git clone https://github.com/fernnf/cassini-dataplane.git

RUN cp -r /root/cassini-dataplane/docker/odtn/yang /root
RUN cp -r /root/cassini-dataplane/docker/odtn/config /root
RUN cp -r /root/cassini-dataplane/docker/odtn/script /root

RUN rm -rf /root/cassini-dataplane

ENV LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib

RUN echo "export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib" >> ~/.bashrc

RUN cd ~ && git clone http://git.libssh.org/projects/libssh.git \
    && cd libssh && mkdir build && cd build \
    && git checkout stable-0.8 \
    && cmake .. && make -j4 && make install

RUN cd ~ && git clone https://git.cryptomilk.org/projects/cmocka.git \
    && cd cmocka && mkdir build && cd build \
    && git checkout tags/cmocka-1.0.1 \
    && cmake .. && make && make install

RUN cd ~ && git clone https://github.com/CESNET/libyang \
    && cd libyang && git checkout v0.16-r3 \
    && mkdir build && cd build && cmake -DGEN_LANGUAGE_BINDINGS=1 .. \
    && make -j4 && make install

RUN cd ~ && git clone https://github.com/CESNET/libnetconf2.git \
    && cd libnetconf2 && git checkout v0.12-r1 \
    && mkdir build && cd build && cmake -DENABLE_TLS=ON -DENABLE_SSH=ON .. \
    && make -j4 && make install

RUN cd ~ && git clone https://github.com/sysrepo/sysrepo.git \
    && cd sysrepo && git checkout v0.7.9 \
    && mkdir build && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release -DGEN_LANGUAGE_BINDINGS=1 -DGEN_PYTHON_VERSION="3" -DCMAKE_INSTALL_PREFIX:PATH=/usr .. \
    && make -j4 \
    && make install

RUN cd ~ && git clone https://github.com/CESNET/Netopeer2.git \
    && cd Netopeer2/ && git checkout v0.7-r1 && cd server \
    && sed -i 's/gnu11/gnu11 -fcommon/' CMakeLists.txt \
    && mkdir build && cd build && cmake .. \
    && make -j4 && make install

RUN ls /root/yang/openconfig-odtn

RUN  python3 -m pip install -U pip

RUN ssh-keygen -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key \
    && echo "root:root" | chpasswd \
    && cd /root/yang/openconfig-odtn && sh import-yangs.sh \
    && pip3 install netconf-console pyfiglet docker

RUN apt-get install -y openvswitch-switch python3-openvswitch openssh-server

RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
    && echo "KexAlgorithms +diffie-hellman-group1-sha1" >> /etc/ssh/sshd_config \
    && echo "Ciphers +aes128-cbc" >> /etc/ssh/sshd_config

RUN ssh-keygen -A

ENV NOTVISIBLE "in users profile"

RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 830
EXPOSE 22
EXPOSE 8080

RUN chmod +x /root/script/push-data.sh
WORKDIR /root

LABEL br.rnp.label.name="cassini-odtn"\
      br.rnp.label.description="SDN transponder cassini from ODTN"\
      br.rnp.label.vendor="National Network for Education and Research - RNP"\
      br.rnp.label.contact="fernando.farias@rnp.br"\
      br.rnp.label.application="CNetLab"\
      br.rnp.label.version="0.1"\
      br.rnp.label.license="Apache2"

CMD ["/root/script/push-data.sh"]

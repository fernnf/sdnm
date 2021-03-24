FROM stratumproject/build:build as builder

ENV BUILD_DEPS \
    python-setuptools \
    python-pip \
    help2man
RUN apt-get update && \
    apt-get install -y --no-install-recommends ${BUILD_DEPS}

WORKDIR /

RUN git clone -b 2020-12-18 https://github.com/stratum/stratum.git

WORKDIR /stratum

RUN bazel build //stratum/hal/bin/bmv2:stratum_bmv2

RUN mkdir -p /output/usr/local/bin

RUN cp ./bazel-bin/stratum/hal/bin/bmv2/stratum_bmv2 /output/usr/local/bin
RUN cp --parents /usr/local/lib/libsimpleswitch_runner.so.0 /output
RUN cp --parents /usr/local/lib/libbmpi.so.0 /output

ARG PROTOBUF_VER=3.7.1
ARG GRPC_VER=1.28.1
RUN pip install --root /output "protobuf<=${PROTOBUF_VER}"
RUN pip install --root /output "grpcio<=${GRPC_VER}"

RUN bazel build @com_github_p4lang_p4runtime//:p4runtime_proto \
    @com_google_protobuf//:protobuf_python \
    @com_google_googleapis//google/rpc/... \
    @com_github_grpc_grpc//src/compiler:grpc_python_plugin
ENV PYTHON_PACKAGE_BASE /output/usr/local/lib/python2.7/dist-packages
RUN ./bazel-out/host/bin/external/com_google_protobuf/protoc \
    ./bazel-stratum/external/com_github_p4lang_p4runtime/p4/v1/p4data.proto \
    ./bazel-stratum/external/com_github_p4lang_p4runtime/p4/v1/p4runtime.proto \
    ./bazel-stratum/external/com_github_p4lang_p4runtime/p4/config/v1/p4info.proto \
    ./bazel-stratum/external/com_github_p4lang_p4runtime/p4/config/v1/p4types.proto \
    ./bazel-stratum/external/com_google_googleapis/google/rpc/status.proto \
    ./bazel-stratum/external/com_google_googleapis/google/rpc/code.proto \
    -I./bazel-stratum/external/com_google_googleapis -I./bazel-stratum/external/com_github_p4lang_p4runtime \
    -I./bazel-stratum/external/com_google_protobuf/src \
    --python_out $PYTHON_PACKAGE_BASE --grpc_out $PYTHON_PACKAGE_BASE  \
    --plugin=protoc-gen-grpc=./bazel-bin/external/com_github_grpc_grpc/src/compiler/grpc_python_plugin
RUN touch $PYTHON_PACKAGE_BASE/p4/__init__.py && \
    touch $PYTHON_PACKAGE_BASE/p4/v1/__init__.py && \
    touch $PYTHON_PACKAGE_BASE/p4/config/__init__.py && \
    touch $PYTHON_PACKAGE_BASE/p4/config/v1/__init__.py \
    touch $PYTHON_PACKAGE_BASE/google/__init__.py && \
    touch $PYTHON_PACKAGE_BASE/google/rpc/__init__.py


FROM bitnami/minideb:stretch as runtime

LABEL br.rnp.label.name="stratum"\
      br.rnp.label.description="Stratum BVM2 Switch"\
      br.rnp.label.vendor="National Network for Education and Research - RNP"\
      br.rnp.label.contact="fernando.farias@rnp.br"\
      br.rnp.label.application="CNetLab"\
      br.rnp.label.version="0.1"\
      br.rnp.label.license="Apache2"

RUN install_packages openssh-client

RUN ssh-keygen -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key \
    && echo "root:root" | chpasswd

RUN install_packages \
    iproute2 \
    iputils-ping \
    net-tools \
    ethtool \
    socat \
    psmisc \
    procps \
    iperf \
    arping \
    telnet \
    python-pexpect \
    tcpdump \
    screen \
    libboost-filesystem1.62.0 \
    libboost-program-options1.62.0 \
    libboost-thread1.62.0 \
    libjudydebian1 \
    libgmp10 \
    libpcap0.8 \
    openssh-server \
    nano \
    curl \
    bridge-utils

RUN install_packages $RUNTIME_DEPS

COPY --from=builder /output /
RUN ldconfig

RUN mkdir -p /etc/stratum/

WORKDIR /etc/stratum
COPY --from=builder /stratum/stratum/hal/bin/bmv2/dummy.json ./dummy.json

WORKDIR /root

ENV PYTHONPATH $PYTHONPATH:/root

EXPOSE 50001

ENV NODEID 1
ENV GRPC_PORT 50001
ENV VPORTS_DEFAULT 10
ENV CPU_PORT 255
ENV DRIVER "stratum-bmv2"
ENV STRATUM_CMD "/usr/local/bin/stratum_bmv2"
ENV PIPECONF "org.onosproject.pipelines.basic"
ENV PS1 "[sdnm:stratum-bmv2 \u@\h:\w]\$ "
ENV LATITUDE 'null'
ENV LONGITUDE 'null'

RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
    && echo "KexAlgorithms +diffie-hellman-group1-sha1" >> /etc/ssh/sshd_config \
    && echo "Ciphers +aes128-cbc" >> /etc/ssh/sshd_config

   RUN ssh-keygen -A

ENV NOTVISIBLE "in users profile"

RUN echo "export VISIBLE=now" >> /etc/profile

RUN mkdir /run/sshd && /usr/sbin/sshd

EXPOSE 22

COPY entrypoint.sh .

COPY gencfg.py .

CMD ["/bin/bash", "entrypoint.sh"]

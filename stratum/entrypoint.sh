#!/usr/bin/env bash

function create_cfg() {
python3 gencfg.py

cat << EOF >/etc/stratum/netcfg.sh
#!/usr/bin/env bash
curl -sSL --user onos:rocks --noproxy localhost -X POST -H 'Content-Type:application/json' http://${IPADDR}:8181/onos/v1/network/configuration/ -d@onos-cfg.json
EOF

chmod +x /etc/stratum/netcfg.sh
}

function create_interfaces() {

  IPROUTE=/bin/ip

  for ((i = 1; i <= ${VPORTS_DEFAULT}; i++)); do
    ${IPROUTE} link add ${HOSTNAME}-veth$i type veth peer name ${HOSTNAME}-p$i
    ${IPROUTE} link set ${HOSTNAME}-veth$i mtu 9000
    ${IPROUTE} link set ${HOSTNAME}-p$i mtu 9000
    ${IPROUTE} link set ${HOSTNAME}-veth$i up
    ${IPROUTE} link set ${HOSTNAME}-p$i up
    ${IPROUTE} link add name port$i type bridge
    ${IPROUTE} link set port$i mtu 9000
    ${IPROUTE} link set port$i up
    ${IPROUTE} link set ${HOSTNAME}-p$i master port$i
  done
}

function run_stratum() {

  touch /etc/stratum/pipeline_cfg.pb.txt
  touch /etc/stratum/p4_writes.pb.txt
  chown root:root /etc/stratum/pipeline_cfg.pb.txt
  chown root:root /etc/stratum/p4_writes.pb.txt

  ${STRATUM_CMD} -device_id=${NODEID} \
    -persistent_config_dir=/etc/stratum \
    -initial_pipeline=/etc/stratum/dummy.json \
    -forwarding_pipeline_configs_file=/etc/stratum/pipeline_cfg.pb.txt \
    -cpu_port=${CPU_PORT} \
    -write_req_log_file=/etc/stratum/p4_writes.pb.txt \
    -external_stratum_urls=0.0.0.0:${GRPC_PORT} \
    -local_stratum_url=localhost:${GRPC_PORT} \
    -max_num_controllers_per_node=10 \
    -logtostderr=true \
    -bmv2_log_level=info
}


# shellcheck disable=SC2155
export IPADDR="$(hostname -I | xargs)"

/usr/sbin/sshd
create_interfaces
create_cfg
run_stratum

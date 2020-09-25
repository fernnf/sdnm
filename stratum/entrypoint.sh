#!/usr/bin/env bash

function create_chassi() {

  cat <<EOF >/etc/stratum/chassi-config.txt
description: "stratum_bvm2 sdn-multilayer"
chassis {
  platform: PLT_P4_SOFT_SWITCH
  name: "${HOSTNAME}"
}
nodes {
  id: ${NODEID}
  name: "${HOSTNAME} node ${NODEID}"
  slot: 1
  index: 1
}\n
EOF
  echo " " >>/etc/stratum/chassi-config.txt

  for ((i = 1; i <= ${VPORTS_DEFAULT}; i++)); do
    cat <<FOE >>/etc/stratum/chassi-config.txt
singleton_ports {
  id : $i
  name: "${HOSTNAME}-veth$i"
  slot: 1
  port: $i
  channel: 1
  speed_bps: 10000000000
  config_params {
    admin_state: ADMIN_STATE_ENABLED
  }
  node: ${NODEID}
}\n
FOE
    echo " " >>/etc/stratum/chassi-config.txt
  done
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

function create_onos_config() {
cat <<EOF >/etc/stratum/onos-config.json
{
  "devices": {
    "device:${HOSTNAME}": {
      "basic": {
        "managementAddress": "grpc://${IPADDR}:${GRPC_PORT}?device_id=${NODEID}",
        "driver": "stratum-bmv2",
        "pipeconf": "${PIPECONF}",
      }
    }
  }
}\n
EOF

cat <<EOF >/etc/stratum/netcfg.sh
#!/usr/bin/env bash
curl -sSL --user onos:rocks --noproxy localhost -X POST -H 'Content-Type:application/json' http://${IPADDR}:8181/onos/v1/network/configuration/ -d@onos-config.json
EOF

chmod +x /etc/stratum/netcfg.sh

}
export IPADDR="$(hostname -I | xargs)"

/usr/sbin/sshd
create_interfaces
create_chassi
create_onos_config
run_stratum

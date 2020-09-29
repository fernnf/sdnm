import os
import json

header = """description: "stratum_bmv2 {name}"
chassis {{
  platform: PLT_P4_SOFT_SWITCH
  name: "{name}"
}}
nodes {{
  id: {nd}
  slot: 1
  index: 1
}}\n"""

port = """singleton_ports {{
  id: {portnum}
  name: "{portname}"
  slot: 1
  port: {portnum}
  channel: 1
  speed_bps: 100000000000
  config_params {{
    admin_state: ADMIN_STATE_ENABLED
  }}
  node: {nodeid}
}}\n"""


def create_chassis():
    nodeid = os.getenv("NODEID")
    name = os.getenv("HOSTNAME")
    num = os.getenv("VPORTS_DEFAULT")

    config = header.format(name=name, nd=nodeid)
    for i in range(1, int(num)):
        config = config + port.format(portnum=i, nodeid=nodeid, portname="port{}".format(i))

    with open('/etc/stratum/chassis-config.txt', 'w') as file:
        file.write(config)


def create_cfg_onos():
    address = "grpc://{}:{}?device_id={}".format(os.getenv("IPADDR"), os.getenv("GRPC_PORT"), os.getenv("NODEID"))
    device = "device:{}".format(os.getenv("HOSTNAME"))
    pipeconf = os.getenv("PIPECONF")


    config = {
        'devices': {
            device: {
                'basic': {
                    "managementAddress": address,
                    "driver": "stratum-bmv2",
                    "pipeconf": pipeconf
                }
            }
        }
    }

    with open("/etc/stratum/onos-cfg.json", 'w') as f:
        json.dump(config, f, indent=2)


create_chassis()
create_cfg_onos()
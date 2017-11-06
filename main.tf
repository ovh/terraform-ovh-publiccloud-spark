## DEPLOY A SPARK Standalone CLUSTER in OVH Public Cloud
## These templates show an example of how to use the spark-cluster
## module to deploy spark in OVH.
## Note that this template assume that the Glance Image you provide via the
## image_id input variable is built from the
## examples/spark-glance-image/coreos-spark.json Packer template.
provider "openstack" {
  alias  = "${var.region}"
  region = "${var.region}"
}

terraform {
  required_version = ">= 0.9.3"
}

# AUTOMATICALLY LOOK UP THE LATEST PRE-BUILT GLANCE IMAGE
#
# NOTE: This Terraform data source must return at least one Image result or the entire template will fail.
data "openstack_images_image_v2" "spark" {
  provider    = "openstack.${var.region}"
  count       = "${var.image_id == "" ? 1 : 0}"
  name        = "${lookup(var.image_names, var.region)}"
  most_recent = true
}

resource "openstack_networking_secgroup_v2" "spark_sg" {
  provider = "openstack.${var.region}"

  name        = "${var.name}_spark_sg"
  description = "${var.name} security group for spark nodes"
}

resource "openstack_networking_secgroup_rule_v2" "in_traffic" {
  provider = "openstack.${var.region}"
  count    = "${var.slaves_count > 0 ? 1  : 0 }"

  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = "${openstack_networking_secgroup_v2.spark_sg.id}"
  security_group_id = "${openstack_networking_secgroup_v2.spark_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "out_traffic" {
  provider = "openstack.${var.region}"
  count    = "${var.slaves_count > 0 ? 1  : 0 }"

  direction         = "egress"
  ethertype         = "IPv4"
  remote_group_id   = "${openstack_networking_secgroup_v2.spark_sg.id}"
  security_group_id = "${openstack_networking_secgroup_v2.spark_sg.id}"
}

resource "openstack_networking_port_v2" "port_master" {
  provider = "openstack.${var.region}"
  count    = "${var.spark_master_url == "" ? 1 : 0}"

  name               = "${var.name}_spark_master_port"
  network_id         = "${var.network_id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_networking_secgroup_v2.spark_sg.id}"]

  fixed_ip {
    subnet_id = "${var.subnet_id}"
  }
}

resource "openstack_networking_port_v2" "port_slaves" {
  provider = "openstack.${var.region}"
  count    = "${var.slaves_count}"

  name               = "${var.name}_spark_master_port_${count.index}"
  network_id         = "${var.network_id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_networking_secgroup_v2.spark_sg.id}"]

  fixed_ip {
    subnet_id = "${var.subnet_id}"
  }
}

resource "openstack_compute_instance_v2" "master" {
  provider = "openstack.${var.region}"
  count    = "${var.spark_master_url == "" ? 1 : 0}"
  name     = "${var.name}_spark_master"
  image_id = "${element(coalescelist(data.openstack_images_image_v2.spark.*.id, list(var.image_id)), 0)}"

  flavor_name = "${var.master_flavor_name != "" ? var.master_flavor_name : (var.master_flavor_id == "" ? lookup(var.master_flavor_names, var.region) : "")}"
  flavor_id   = "${var.master_flavor_id}"
  user_data   = <<CLOUDCONFIG
#cloud-config
## This route has to be added in order to reach other subnets of the network
bootcmd:
  - ip route add ${var.cidr} dev eth0 scope link metric 0
runcmd:
  - systemctl daemon-reload
  - systemctl enable spark-master.service spark-ui-proxy.service
  - systemctl start spark-master.service spark-ui-proxy.service
write_files:
  - path: /etc/sysconfig/network-scripts/route-eth0
    content: |
      ${var.cidr} dev eth0 scope link metric 0
  - path: /etc/systemd/system/spark-master.service.d/01-spark-master.conf
    content: |
      [Service]
      Environment=SPARK_MASTER_HOST=${openstack_networking_port_v2.port_master.all_fixed_ips[0]}
      Environment=SPARK_LOCAL_IP=${openstack_networking_port_v2.port_master.all_fixed_ips[0]}
  - path: /etc/systemd/system/spark-ui-proxy.service.d/01-spark-master.conf
    content: |
      [Service]
      Environment=SPARK_MASTER_HOST=${openstack_networking_port_v2.port_master.all_fixed_ips[0]}
CLOUDCONFIG

  key_pair    = "${var.ssh_key_pair}"

  network {
    access_network = true
    port           = "${openstack_networking_port_v2.port_master.id}"
  }

  metadata = "${var.metadata}"
}

resource "openstack_compute_instance_v2" "slaves" {
  provider = "openstack.${var.region}"
  count    = "${var.slaves_count}"
  name     = "${var.name}_spark_slave_${count.index}"
  image_id = "${element(coalescelist(data.openstack_images_image_v2.spark.*.id, list(var.image_id)), 0)}"

  flavor_name = "${var.slave_flavor_name != "" ? var.slave_flavor_name : (var.slave_flavor_id == "" ? lookup(var.slave_flavor_names, var.region) : "")}"
  flavor_id   = "${var.slave_flavor_id}"
  user_data   = <<CLOUDCONFIG
#cloud-config
## This route has to be added in order to reach other subnets of the network
bootcmd:
  - ip route add ${var.cidr} dev eth0 scope link metric 0
runcmd:
  - systemctl daemon-reload
  - systemctl enable spark-slave.service
  - systemctl start spark-slave.service
write_files:
  - path: /etc/modprobe.d/nvidia.conf
    content: |
      ${var.with_cuda_support ? "nvidia" : "#nvidia"}
  - path: /etc/sysconfig/network-scripts/route-eth0
    content: |
      ${var.cidr} dev eth0 scope link metric 0
  - path: /etc/systemd/system/spark-slave.service.d/01-spark.conf
    content: |
      [Service]
      Environment=SPARK_MASTER_URL=${var.spark_master_url != "" ? var.spark_master_url : join("",formatlist("spark://%s:7077", flatten(openstack_networking_port_v2.port_master.*.all_fixed_ips)))}
      Environment=SPARK_LOCAL_IP=${join("", openstack_networking_port_v2.port_slaves.*.all_fixed_ips[count.index])}
CLOUDCONFIG

  key_pair    = "${var.ssh_key_pair}"

  network {
    access_network = true
    port           = "${openstack_networking_port_v2.port_slaves.*.id[count.index]}"
  }

  metadata = "${var.metadata}"
}

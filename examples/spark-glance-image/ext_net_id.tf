variable "region" {
   description = "the openstack region"
}

variable "ext_net_name" {
   default = "Ext-Net"
}

provider "openstack" {
   region = "${var.region}"
}

data "openstack_networking_network_v2" "ext_net" {
   region = "${var.region}"
   name = "${var.ext_net_name}"
   tenant_id = ""
}

output "ext_net_id" {
   value = "${data.openstack_networking_network_v2.ext_net.id}"
}

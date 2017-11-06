output "security_group_id" {
  value = "${openstack_networking_secgroup_v2.spark_sg.id}"
}

output "slaves_instance_ids" {
  value = ["${flatten(openstack_compute_instance_v2.slaves.*.id)}"]
}

output "master_instance_id" {
  value = "${openstack_compute_instance_v2.master.id}"
}

output "slaves_ipv4_addrs" {
  value = ["${flatten(openstack_networking_port_v2.port_slaves.*.all_fixed_ips)}"]
}

output "master_ipv4_addr" {
  value = "${element(openstack_networking_port_v2.port_master.all_fixed_ips,0)}"
}

output "spark_master_url" {
  value = "${var.spark_master_url != "" ? var.spark_master_url : format("spark://%s:7077", openstack_networking_port_v2.port_master.all_fixed_ips[0])}"
}

output "helper" {
  value = <<HELPER
Your spark cluster has been deployed. You can access the spark ui on:

   http://${element(openstack_networking_port_v2.port_master.all_fixed_ips,0)}:9999

The spark master url of your cluster is:

   ${var.spark_master_url != "" ? var.spark_master_url : format("spark://%s:7077", openstack_networking_port_v2.port_master.all_fixed_ips[0])}


Enjoy your ML!
HELPER
}

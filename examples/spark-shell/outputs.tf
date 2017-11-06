output "helper" {
  description = "human friendly helper"

  value = <<DESC
The nat gateway has been setup to allow ssh traffic from 0.0.0.0/0

You may want to configure your ‘~/.ssh/config‘ as follows:
---
$ cat >> ~/.ssh/config <<EOF
Host 10.2.*
  User centos
  ProxyCommand ssh core@${module.network.nat_public_ips[0]} ncat %h %p
EOF
---

and then ssh into your private boxes by typing:
---
# master node
$ ssh ${module.spark_cluster.master_ipv4_addr}
# slaves nodes
$ ssh ${module.spark_cluster.slaves_ipv4_addrs[Ø]}
$ ssh ${module.spark_cluster.slaves_ipv4_addrs[1]}
$ ssh ${module.spark_cluster.slaves_ipv4_addrs[2]}
---

You can also access your spark ui through an ssh tunnel

$ ssh -fnNqT -L 9999:${module.spark_cluster.master_ipv4_addr}:9999 ${module.spark_cluster.master_ipv4_addr}

and start browsing:

http://localhost:9999

Don't forget to `terraform destroy` your environment as this scripts spawn resources with associated costs.
DESC
}

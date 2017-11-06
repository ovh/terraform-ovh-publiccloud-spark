## This example requires that you already have attached your openstack project
## your OVH Vrack
provider "ovh" {
  endpoint = "ovh-eu"
}

provider "openstack" {
  region = "${var.region}"
}

# Import Keypair
resource "openstack_compute_keypair_v2" "keypair" {
  name       = "spark-example-keypair"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

module "network" {
  source = "ovh/publiccloud-network/ovh"

  project_id      = "${var.project_id}"
  attach_vrack    = false
  name            = "spark-test-network"
  cidr            = "10.2.0.0/16"
  region          = "${var.region}"
  public_subnets  = ["10.2.0.0/24"]
  private_subnets = ["10.2.1.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  nat_as_bastion     = true

  ssh_public_keys = ["${openstack_compute_keypair_v2.keypair.public_key}"]

  metadata = {
    Terraform   = "true"
    Environment = "Dev"
  }
}

resource "ovh_publiccloud_user" "spark_job" {
  description = "spark job user for terraform example"
  project_id  = "${var.project_id}"
}

resource "openstack_objectstorage_container_v1" "datalake" {
  region         = "${var.region}"
  name           = "spark-test-datalake"
  container_read = "${ovh_publiccloud_user.spark_job.username}"
}

resource "openstack_objectstorage_object_v1" "dataset" {
  container_name = "${openstack_objectstorage_container_v1.datalake.name}"
  name           = "mydataset.csv"
  content_type   = "text/csv"
  source         = "./dataset.csv"
  etag           = "${md5(file("./dataset.csv"))}"
}

module "spark_cluster" {
  source       = "ovh/publiccloud-spark/ovh"
  name         = "myspark_cluster"
  count        = 3
  cidr         = "10.2.0.0/16"
  image_id     = "b141b962-9c95-42f2-85ad-0571514f56b8"
  network_id   = "${module.network.network_id}"
  subnet_id    = "${module.network.private_subnets[0]}"
  ssh_key_pair = "${openstack_compute_keypair_v2.keypair.name}"

  metadata = {
    Terraform   = "true"
    Environment = "Spark Terraform Test"
  }
}

data "template_file" "spark_script" {
  template = "${file("spark-script.scala")}"

  vars {
    os_tenant_name       = "${var.tenant_name}"
    os_username          = "${ovh_publiccloud_user.spark_job.username}"
    os_password          = "${ovh_publiccloud_user.spark_job.password}"
    os_region            = "${var.region}"
    swift_container_name = "${openstack_objectstorage_object_v1.dataset.container_name}"
    swift_object_name    = "${openstack_objectstorage_object_v1.dataset.name}"
  }
}

resource "null_resource" "cluster" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    master_instance_id  = "${module.spark_cluster.master_instance_id}"
    slaves_instance_ids = "${join(",", module.spark_cluster.slaves_instance_ids)}"
    script              = "${data.template_file.spark_script.rendered}"
    dataset_etag        = "${openstack_objectstorage_object_v1.dataset.etag}"
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host                = "${module.spark_cluster.master_ipv4_addr}"
    user                = "centos"
    private_key         = "${file("~/.ssh/id_rsa")}"
    bastion_host        = "${module.network.nat_public_ips[0]}"
    bastion_user        = "core"
    bastion_private_key = "${file("~/.ssh/id_rsa")}"
  }

  # Copies the string in content into /tmp/file.log
  provisioner "file" {
    content     = "${data.template_file.spark_script.rendered}"
    destination = "/tmp/spark-script.scala"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    inline = ["cat /tmp/spark-script.scala | spark-shell --packages org.apache.hadoop:hadoop-openstack:2.7.4"]
  }
}

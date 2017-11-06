variable "image_id" {
  description = "The ID of the glance image to run in the cluster. This should be an image built from the Packer template under examples/spark-glance-image/sparkjson. If the default value is used, Terraform will look up the latest image build automatically."
  default     = ""
}

variable "image_names" {
  type        = "map"
  description = "The name per region of the spark glance image. This variable can be overriden by the \"image_id\" variable"

  default = {
    GRA1 = "CentOS 7 Spark"
    SBG3 = "CentOS 7 Spark"
    GRA3 = "CentOS 7 Spark"
    SBG3 = "CentOS 7 Spark"
    BHS3 = "CentOS 7 Spark"
    WAW1 = "CentOS 7 Spark"
    DE1  = "CentOS 7 Spark"
  }
}

variable "master_flavor_name" {
  description = "the name of the flavor that will be used for the spark master"
  default     = ""
}

variable "slave_flavor_name" {
  description = "the name of the flavor that will be used for spark slaves"
  default     = ""
}

variable "master_flavor_id" {
  description = "the id of the flavor that will be used for the spark master"
  default     = ""
}

variable "slave_flavor_id" {
  description = "the id of the flavor that will be used for spark slaves"
  default     = ""
}

variable "spark_master_url" {
  description = "The url of an existing spark master node. Setting this variable will disable the spawning of a spark master node by this module."
  default     = ""
}

variable "with_cuda_support" {
  description = "If true, slave nodes will try to load the nvidia module during boot process"
  default     = false
}

variable "master_flavor_names" {
  type = "map"

  description = "A map of flavor names per openstack region that will be used for the spark master."

  default = {
    GRA1 = "s1-4"
    SBG3 = "s1-4"
    GRA3 = "s1-4"
    SBG3 = "s1-4"
    BHS3 = "s1-4"
    WAW1 = "s1-4"
    DE1  = "s1-4"
  }
}

variable "slave_flavor_names" {
  type = "map"

  description = "A map of flavor names per openstack region that will be used for spark servers."

  default = {
    GRA1 = "b2-15"
    SBG3 = "b2-15"
    GRA3 = "b2-15"
    SBG3 = "b2-15"
    BHS3 = "b2-15"
    WAW1 = "b2-15"
    DE1  = "b2-15"
  }
}

variable "region" {
  description = "The OVH region to deploy into (e.g. GRA3, BHS3, ...)."
  default     = "GRA3"
}

variable "name" {
  description = "What to name the Spark cluster and all of its associated resources."
  default     = "mysparkcluster"
}

variable "slaves_count" {
  description = "The number of Spark slaves to deploy."
  default     = 3
}

variable "cidr" {
  description = "The CIDR block of the Network. (e.g. 10.0.0.0/16)"
}

variable "network_id" {
  description = "The id of the network in which the servers will be spawned."
}

variable "subnet_id" {
  description = "The id of the subnet in which the servers will be spawned."
}

variable "ssh_key_pair" {
  description = "The name of an  key pair that can be used to SSH to the instances in this cluster. Set to an empty string to not associate a Key Pair."
  default     = ""
}

variable "metadata" {
  description = "A map of metadata to add to all resources supporting it."
  default     = {}
}

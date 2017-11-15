# Apache Spark Standalone Cluster OVH Public Cloud Module

This repo contains a Module for how to deploy an [Apache Spark](https://spark.apache.org/) standalone cluster on [OVH Public Cloud](https://ovhcloud.com/) using [Terraform](https://www.terraform.io/). Apache Spark™ is a fast and general engine for large-scale data processing.

## Important Note

This setup is suitable for temporary or development apache spark standalone clusters. It is not suitable for long running production clusters, with a proper HA setup, history servers, ... 

# Usage


```hcl
module "spark_cluster" {
  source = "terraform-ovh-modules/publiccloud_spark/ovh"
  name         = "myspark_cluster"
  count        = 3
  cidr         = "10.2.0.0/16"
  network_id   = "xxx"
  subnet_id    = "yyy"
  ssh_key_pair = "zzz"

  metadata = {
    Terraform   = "true"
    Environment = "Spark Terraform Test"
  }
}
```

## Examples

This Module has the following folder structure:

* [root](https://github.com/ovh/terraform-ovh-publiccloud-spark/tree/master): This folder shows an example of Terraform code which deploys a [Standalone Spark Cluster](https://spark.apache.org/docs/latest/spark-standalone.html#installing-spark-standalone-to-a-cluster) suitable for on-demand apache spark workloads in [OVH Public Cloud](https://ovhcloud.com/).
* [modules](https://github.com/ovh/terraform-ovh-publiccloud-spark/tree/master/modules): This folder contains the reusable code for this Module, broken down into one or more modules.
* [examples](https://github.com/ovh/terraform-ovh-publiccloud-spark/tree/master/examples): This folder contains examples of how to use the modules.

To deploy Standalone Spark Clusters using this Module:

1. Create a Spark Glance Image using a Packer template that references the [install-spark module](https://github.com/ovh/terraform-ovh-publiccloud-spark/tree/master/modules/install-spark).
   Here is an [example Packer template](https://github.com/ovh/terraform-ovh-publiccloud-spark/tree/master/examples/spark-glance-image#quick-start). 
      
1. Deploy that Image using the Terraform [spark-shell example](https://github.com/ovh/terraform-ovh-publiccloud-spark/tree/master/examples/spark-shell) 

## How do I contribute to this Module?

Contributions are very welcome! Check out the [Contribution Guidelines](https://github.com/ovh/terraform-ovh-publiccloud-spark/tree/master/CONTRIBUTING.md) for instructions.

## Authors

Module managed by [Yann Degat](https://github.com/yanndegat).

This module was originally based on the [terraform-aws-consul module](https://github.com/hashicorp/terraform-aws-consul/) by [Gruntwork](https://gruntowrk.io)

## License

OVH Licensed. See [LICENSE](https://github.com/ovh/terraform-ovh-publiccloud-spark/tree/master/LICENSE) for full details.

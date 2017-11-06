# Apache Spark Glance Image

This folder shows an example of how to use the [install-spark](../../modules/install-spark) module with [Packer](https://www.packer.io/) to create an [Openstack Glance Image](https://docs.openstack.org/glance/latest/) that has Apache Spark installed on top of CensOS 7.

This image will have the proper setup to spawn a ready to use [Standalone Spark Cluster](https://spark.apache.org/docs/latest/spark-standalone.html#installing-spark-standalone-to-a-cluster) suitable for on-demand apache spark workloads. To see how to deploy this image, check out the [module's main script](../../README.md). 

For more info on Apache spark installation and configuration, check out the 
[install-spark](../../modules/install-spark) documentation.

## Quick start

To build the Spark Glance Image:

1. `git clone` this repo to your computer.
1. Install [Packer](https://www.packer.io/).
1. Configure your Openstack credentials using one of the [options supported by the Openstack 
API](https://developer.openstack.org/api-guide/quick-start/api-quick-start.html). 
1. Update the `variables` section of the `centos7-spark.json` Packer template to configure the Openstack region, Spark version you wish to use.
1. Run `packer build centos7-spark.json`.
1. Or run `make centos7-spark`.

When the build finishes, it will output the ID of the new Glance Image. To see how to deploy this image, check out the [module's main script](../../README.md).

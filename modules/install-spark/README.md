# Apache Spark Ansible Install Playbook

This folder contains an [Ansible](https://ansbile.com) playbook for installing Apache Spark and its dependencies. Use this playbook to create an Apache Spatk [Openstack Glance Image](https://docs.openstack.org/glance/latest/) that can be deployed in [OVH Public Cloud](https://www.ovh.com/fr/public-cloud/instances/).

This playbook has been tested on the CentOS 7 operating system.

There is a good chance it will work on other flavors of CentOS and RHEL as well.

## Quick start

<!-- TODO: update the clone URL to the final URL when this Module is released -->

To install Apache Spark, use `git` to clone this repository at a specific tag (see the [releases page](../../../../releases) 
for all available tags) and run the `ansible/playbook.yml` playbook:

```
git clone --branch <VERSION> https://github.com/ovh/terraform-ovh-publiccloud-spark.git
ansible-playbook -i Your_inventory terraform-ovh-publiccloud-spark/modules/install-spark/ansible/playbook.yml --extra-vars spark_version=2.2.0 spark_sha256sum=97fd2cc58e08975d9c4e4ffa8d7f8012c0ac2792bcd9945ce2a561cf937aebcc
```

The `install-spark` playbook will install Spark, its dependencies, and systemd services to either run an apache spark master node, or a slave one.

We recommend running the `install-spark` script as part of a [Packer](https://www.packer.io/) template to create an Apache Spark [Glance Image](https://docs.openstack.org/glance/latest/) (see the 
[spark-glance-image example](../../examples/spark-glance-image) for a fully-working sample code). You can then deploy the image with the proper userdata configuration to spawn a [Standalone Spark Cluster](https://spark.apache.org/docs/latest/spark-standalone.html#installing-spark-standalone-to-a-cluster) (see the [main terraform script](../../README.md) for fully-working sample code).

## Command line Arguments

The `playbook.yml` script accepts the following arguments:

* `spark_version`       : The apache spark version, Defaults to '2.2.0'.
* `spark_hadoop_ver`    : The hadoop version of the spark build. Default to 'hadoop2.7'.
* `spark_mirror_url`    : The apache spark mirror url. Defaults to 'http://mirrors.sonic.net/apache/spark'.
* `spark_sha256sum`     : The apache spark binay sha256 checksum. Defaults to '97fd2cc58e08975d9c4e4ffa8d7f8012c0ac2792bcd9945ce2a561cf937aebcc'.
* `spark_parent_dir`    : The parent directory in which the apache spark bundle will be installed. Defaults to '/opt'.
* `spark_timeout`       : The download timeout in seconds. Defauts to '10'.
* `spark_cleanup`       : Determines if the scripts cleans up installation scripts. Defaults to 'True'.
* `spark_name`          : Used to forge the binary download URL and the install directory. Defaults to 'spark-{{spark_version}}'. You may not want to override this value.
* `spark_hadoop_name`   : Used to forge the binary download URL and the install directory. Defaults to '{{spark_name}}-bin-{{spark_hadoop_ver}}'. You may not want to override this value.
* `spark_tgz`           : Used to forge the binary download URL and the install directory. Defaults to '{{spark_hadoop_name}}.tgz'. You may not want to override this value.
* `spark_url`           : The URL of the apache spark binary to download. Defaults to '{{spark_mirror_url}}/{{spark_name}}/{{spark_tgz}}'.
* `spark_target_dir`    : The apache spark install directory. Defaults to '{{spark_parent_dir}}/{{spark_hadoop_name}}'.
* `spark_link_dir`      : The apache spark convenient link directory used by systemd services. Defaults to '{{spark_parent_dir}}/spark'.
* `with_python_ml`      : Installs python and numpy latest library. Defaults to 'True'.
* `with_spark_ui_proxy` : Installs [Spark UI Proxy](https://github.com/aseigneurin/spark-ui-proxy/). Defaults to 'True'.

Example:

```
ansible-playbook -i Your_inventory ./ansible/playbook.yml --extra-vars spark_version=2.2.0 spark_sha256sum=97fd2cc58e08975d9c4e4ffa8d7f8012c0ac2792bcd9945ce2a561cf937aebcc
```

### Notes

* As of today, its important to note that the playbook disables the firewalld service.
We shall include a proper apache spark firewalld config in a further release.

* This setup is suitable for temporary or development apache spark standalone clusters. It is not suitable for long running production clusters, with a proper HA setup, history servers, ...

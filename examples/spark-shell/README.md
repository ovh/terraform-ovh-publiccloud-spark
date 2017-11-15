Apache Spark on demand Job processing example
==========

Configuration in this directory creates set of openstack resources which will spawn all the OVH Public Cloud infrastructure required to process a dataset stored on OVH Public Cloud Storage (based on Openstack Swift) with an Apache spark job script.

It will: 

* Create an openstack keypair used to interact with the standalone spark cluster.
* Create the private network in which the apache spark cluster will be spawned.
* Create a temporary openstack user used by the spark script to get credentials for openstack swift interactions.
* Create an private openstack swift container with Read permissions granted to the previously created openstack user.
* Upload a dataset to this container.
* Spawn a standalone spark cluster with 3 slaves nodes to process the dataset.
* Use a provisionner to execute the spark job through an ssh tunnel.


NOTES:

* In a real scenario, you probably would have your dataset already available on a pre existing Openstack Swift Container.
* As of today, Openstack users created by the script have admin permissions on the openstack tenant. You want to be very precautionnous with the credentials associated with this user.
* Once the spark job is successfull, it may have written its output in the container, alongside with the dataset.
* Once the spark job is successfull and you have retrieved its output, you have to apply a `terraform destroy` command to tear down all the OVH Public Cloud resources.
* You may want to refer to the [network module](https://github.com/ovh/terraform-ovh-publiccloud-network) to see how to associate a VRack to your project, use a preexisting network, spawn the cluster in a specific VLAN ID, ...

Usage
=====

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan -var project_id=...
$ terraform apply -var project_id=...
...
$ terraform destroy -var project_id=...
```

Note that this example may create resources which can cost money (Openstack Instance, for example). Run `terraform destroy` when you don't need these resources.

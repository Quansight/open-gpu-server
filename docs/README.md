# Setup overview

![arch](https://github.com/Quansight/open-gpu-server/assets/5647941/3441d6dd-5dc5-4137-affc-25a066656e45)

* The server runs OpenStack, which is able to spin up VMs on demand. See [`openstack.md`](./openstack.md) for more information.
* The VMs run images built with [`](https://docs.openstack.org/diskimage-builder/latest/). See [`images.md`](./images.md) for more information.
* Cirun knows how to connect to OpenStack to spin up VMs and expose them to Github Actions as self-hosted runners. See [`cirun.md`](./cirun.md) for more information.
* The server is behind a VPN, which prevents public access to the server. See [`network.md`](./network.md) for more information.

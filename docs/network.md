# Network

The GPU Server sits behind a VPN, which prevents public access to the server.

However, Cirun needs access to the OpenStack API to be able to create and destroy runners (VMs). To
tackle this problem we have created a proxy server on GCP whose IP address is allow-listed in the
VPN, so that it can access the GPU server from outside the VPN.

The proxy server points to [ci.quansight.dev](https://ci.quansight.dev).
Apart from providing a gateway to the GPU server it also proxies request to the server,
which is basically being able to access the OpenStack API.

The OpenStack web interface is also accesible at [ci.quansight.dev](ci.quansight.dev/).

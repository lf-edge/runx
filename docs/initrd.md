RunX Initrd Interface
=====================

The RunX initrd (initrd/init-initrd) sets up the environment to run a container application. It creates device nodes, sets up the network, mounts the container filesystem, chroots into it, and executes the required application. In order to perform these operations appropriately, RunX makes some assumptions and retrieves information from special locations. These assumptions and interfaces are documented here.

Filesystem
----------
The RunX initrd reads the filesystem root device from the *root=foo* command line argument (one of the kernel command line arguments of the virtual machine.) If the container filesystem is exposed to the VM using Xen 9pfs, *root=9p* should be used and the name of the Xen 9pfs share has to be *share_dir*.


Network
-------
The RunX initrd reads the network configuration from the following command line arguments (kernel command line arguments):

- ip=address
- gw=address
- route=address

For DHCP, *ip=dhcp* should  be passed.

Otherwise, the three parameters are IP addresses, they can be ipv4 or ipv6. *ip* is the IP used to configure the local network interface; *gw* is the gateway address; *route* is the route (as in *route add -net route-ip-address gw gateway-ip-address eth0*.) The nameserver is assumed to be *8.8.8.8* for ipv4 and *2001:4860:4860::8888* for ipv6.


Command line
------------
The container application to run and its command line arguments (command line arguments for the application) are exposed to the RunX initrd via a special text file at the *root (/)* of the container filesystem. The file is named *cmdline*. The RunX initrd reads the content of the file and uses it to find the application to run and to pass command line arguments to it.

RunX
====

Goals and Scope
---------------
RunX is an OCI Runtime Spec compliant containers runtime that runs
containers as VMs. It can be used together with oci-image-tools to start
containers in multiple separate Virtual Machines for isolation and
security.

RunX is lightweight and as small as possible. It targets
resource-constrained embedded environments. It starts each container in
its own independent VM. RunX provides a custom-built Linux-based kernel
and a tiny Busybox-based ramdisk to boot the VM, but if the container
comes with its own kernel/ramdisk, RunX will use them.

RunX aims at keeping the overhead as low as possible.  It doesn't
attempt to communicate with the host via a side-channel. It is a goal of
the project not to have any agents running inside the VM.

OCI specified runtime lifecycle hooks will be supported, while the
support for specific hook implementations is TBD.


RunX and KataContainers
-----------------------
Both KataContainers and RunX are containers runtimes that use
hypervisors to start containers as virtual machines. However, there are
a few key differences.

KataContainers focuses on KVM-based virtual machines. RunX focuses
on Xen virtual machines. KataContainers uses an agent running inside
each VM, while RunX does not do that by design. RunV (KataContainers'
parent) uses libxl to create Xen VMs; thus, it has a build dependency
on the Xen Dom0 libraries. RunX doesn't have any build or runtime
dependencies on libraries as it invokes the command-line tool ``xl``.


Architecture
------------
    +------------+  +-------------+
    |    Dom0    |  | Tiny Kernel |
    |------------|  |-------------|
    | ContainerD |  |Tiny Busybox |
    |     |      |  | (init only) |
    |    RunX    |  |-------------|
    |     |      |  |  container  |
    |  creates---+->|   rootfs    |
    +------------+--+-------------+
    |             Xen             |
    +-----------------------------+


ContainerD invocation
---------------------

Use the following example config stanza in your
/etc/containerd/config.toml config file to choose RunX as OCI-runtime:

    [plugins.linux]
         runtime="/usr/sbin/runX"


Networking Configuration
------------------------

To get bridge based networking working, you need to include the containerd
option '--env NETCONF="/path/to/cni/file,name[,IP]"', where:
    - NETCONF is the environmental varable we use to pass info from containerd
      to runX
    - /path/to/cni/file is the cni v2.0 file used to describe the interface
    - name is the name of the cni interface
    - [,IP] is the optional IP if static addresses are used, otherwise DHCP

An example cni file is:

```json
{
    "cniVersion": "0.2.0",
    "name": "mynet",
    "type": "bridge",
    "bridge": "xenbr0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "subnet": "192.168.0.0/24",
        "rangeStart": "192.168.0.2",
        "rangeEnd": "192.168.0.255",
        "gateway": "192.168.0.1",
        "routes": [
            { "dst": "192.168.0.0/24" }
        ],
     "dataDir": "/run/ipam-state"
    },
    "dns": {
    "nameservers": [ "8.8.8.8" ]
    }
}
```

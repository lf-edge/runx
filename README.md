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

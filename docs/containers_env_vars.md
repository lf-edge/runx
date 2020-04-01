Containers Environmental Variables
==================================

RunX reads a few special parameters from containers environmental variables (*config.json*). They are meant to be set by the container itself, as opposed to the *System Environmental Variables* that are meant to be set by the user. They are described in this document.


RUNX_KERNEL
-----------

The *RUNX_KERNEL* variable points to a file in the container filesystem (not the host filesystem) to be used by RunX as kernel to start the container. For instance:

    RUNX_KERNEL=/boot/kernel

Where */boot/kernel* comes with the container.


RUNX_RAMDISK
------------

The *RUNX_RAMDISK* variable points to a file in the container filesystem (not the host filesystem) to be used by RunX as ramdisk to start the container. For instance:

    RUNX_RAMDISK=/boot/ramdisk

Where */boot/ramdisk* comes with the container.

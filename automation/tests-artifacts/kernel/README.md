Creating config.diffs
=====================

Start with a defconfig.  Then use the tool at:  
https://github.com/moby/moby/raw/master/contrib/check-config.sh  

Then make sure all the required, overlayfs, and anything else sane  are
all built in.  Once from there, just take a diff, and add the changed
options to the diff.


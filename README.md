CIVM
====

A simple and stupid VM runner for CI.

Ratio
-----

Sometimes it is required to run functional tests on different
Linux distros and on different kernels. There are many complex
solutions to automate this task, but `civm` aims to be as
simple as possible.

Runtime
-------

In the project directory (`.` by default) `civm` expects following
files and dirs:

* `./configs/` -- directory with VM configs in libvirt XML format
* `./urls` -- file with VM disk images urls
* `./pre.sh` -- a shell script to run before VM start
* `./post.sh` -- a shell script to run after VM stop

File formats and sample scripts are in the `examples` directory.

The main process scheme:

* collect disk image names from configs and check if they exist
* if an image is missing, download it and check md5sum
* start up to `maxwid` workers in parallel
* wait for the next free worker and start it with the next config
* wait until all workers are stopped

The worker process scheme:

* reset VM image to `init` snapshot, if exists
* mount VM image to `/var/run/civm/mnt/<wid>`
* run `pre.sh`
* sync FS, umount the image
* start VM
* wait until it stops
* mount VM image to `/var/run/civm/mnt/<wid>`
* run `post.sh`
* sync FS, umount the image

Environment variables provided by worker to scripts:

* `$CIVM_WORKER_MOUNT` -- VM disk mountpoint to access the root FS
* `$CIVM_WORKER_NAME` -- the VM name
* `$CIVM_WORKER_WORKDIR` -- working directory for pre/post scripts

Disk image requirements
-----------------------

The disk image must be in the qcow2 format and must
contain `init` snapshot. The script automatically
reverts the image to the `init` state every time it
is launched. It should contain the only primary partition
with `/` as the mountpoint.

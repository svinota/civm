#!/bin/bash

pushd $CIVM_WORKER_MOUNT >/dev/null
    cd opt
    git clone https://github.com/svinota/pyroute2.git >/dev/null 2>&1
popd >/dev/null

[ -e $CIVM_WORKER_MOUNT/etc/rc.d ] && {
    rc=$CIVM_WORKER_MOUNT/etc/rc.d/rc.local
} || {
    rc=$CIVM_WORKER_MOUNT/etc/rc.local
}

cat >$rc <<EOF
#!/bin/bash

cd /opt/pyroute2
make test
poweroff
EOF
chmod 755 $rc

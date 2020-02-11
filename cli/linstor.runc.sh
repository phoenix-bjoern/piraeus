#!/bin/sh

if [ "$1" = "INSTALL" ]; then
    : ${ROOTFS_DIR:=/opt/piraeus/client/oci/rootfs}
    [ -z $2 ] && IMG=quay.io/piraeusdatastore/piraeus-client || IMG=$2
    echo Extracting image \"${IMG}\" to ${ROOTFS_DIR}
    rm -fr ${ROOTFS_DIR} && \
    mkdir -p ${ROOTFS_DIR} && \
    docker export $( docker create --rm ${IMG} ) \
        | tar -xf - -C ${ROOTFS_DIR}
else
    cd /opt/piraeus/client/oci
    CMD=$( echo \"linstor\",\"--no-utf8\",\"$@\" | sed 's/ /","/g' )
    cat config.json.template \
        | sed "s/_COMMAND_/${CMD}/; s#LS_CONTROLLERS=#&${LS_CONTROLLERS}#" \
        > config.json
    runc run $( uuidgen )
fi

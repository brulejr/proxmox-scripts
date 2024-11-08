#!/bin/bash

function create_template() {
    template_id=$1
    template_name=$2

    echo "Creating template $template_name ($template_id)"

    qm create $template_id --name $template_name --ostype l26
    qm importdisk $template_id ${IMAGE} ${STORAGE}

    qm set $template_id --net0 virtio,bridge=${BRIDGE}
    qm set $template_id --memory ${MEMORY} --cores ${CORES}

    qm set $template_id --scsihw virtio-scsi-pci --scsi0 ${STORAGE}:vm-${template_id}-disk-0
    qm set $template_id --boot c --bootdisk scsi0

    qm set $template_id --serial0 socket --vga serial0

    qm set $template_id --agent enabled=1
    
    qm set $template_id --ide2 ${STORAGE}:cloudinit

    qm set $template_id --ipconfig0 "ip=dhcp"

    qm set $template_id --sshkeys ${SSH_KEYFILE}
    qm set $template_id --ciuser ${USERNAME}

    qm disk resize $template_id scsi0 8G

    qm template $template_id
}

while getopts "b:c:i:k:m:n:s:t:u:?" opt; do
    case ${opt} in
        b) BRIDGE=${OPTARG} ;;
        c) CORES={$CORES} ;;
        i) IMAGE=${OPTARG} ;;
        k) SSH_KEYFILE=${OPTARG} ;;
        m) MEMORY=${OPTARG} ;;
        n) TEMPLATE_NAME=${OPTARG} ;;
        s) STORAGE=${OPTARG} ;;
        t) TEMPLATE_ID=${OPTARG} ;;
        u) USERNAME=${OPTARG} ;;
        ?) printf "Usage: %s: [-s value] [-u value]\n" $0; exit 2 ;;
    esac
done

BRIDGE=${BRIDGE:="vmbr1"}
CORES=${CORES:=1}
IMAGE=${IMAGE?"Missing image"}
MEMORY=${MEMORY:=2048}
SSH_KEYFILE=${SSH_KEYFILE:="/root/templates/id_rsa.pub"}
STORAGE=${STORAGE:="local-lvm"}
USERNAME=${USERNAME:="sysadm"}
TEMPLATE_ID=${TEMPLATE_ID?"Missing template id"}
TEMPLATE_NAME=${TEMPLATE_NAME?"Missing template name"}

create_template $TEMPLATE_ID $TEMPLATE_NAME

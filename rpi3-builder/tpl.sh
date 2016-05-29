set -x
set -e

# Extract root partition from the image to the ZFS volume

kpartx -av Fedora-sda.raw
zfs create -V 20G -s tank/nbd/rpi-template
dd if=/dev/mapper/loop0p2 of=/dev/zvol/tank/nbd/rpi-template
kpartx -d Fedora-sda.raw

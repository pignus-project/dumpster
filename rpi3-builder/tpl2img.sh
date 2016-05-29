set -x
set -e

# Clean up the template

zfs destroy -R tank/nbd/rpi-template@now || :
mount /dev/zvol/tank/nbd/rpi-template /mnt

rm -rf \
/mnt/usr/lib/python3.5/site-packages/dnf-plugins/__pycache__/*.pyc \
/mnt/var/lib/NetworkManager/* \
/mnt/var/lib/dhclient/* \
/mnt/var/lib/chrony/drift \
/mnt/var/.updated \
/mnt/var/cache/dnf/* \
/mnt/var/log/audit/audit.log \
/mnt/var/log/hawkey.log \
/mnt/var/log/boot.log \
/mnt/var/log/dnf.log \
/mnt/var/log/dnf.rpm.log \
/mnt/var/log/dnf.librepo.log \
/mnt/etc/ssh/ssh_host_ecdsa_key \
/mnt/etc/ssh/ssh_host_ed25519_key \
/mnt/etc/ssh/ssh_host_rsa_key \
/mnt/etc/ssh/ssh_host_ecdsa_key.pub \
/mnt/etc/ssh/ssh_host_rsa_key.pub \
/mnt/etc/ssh/ssh_host_ed25519_key.pub \
/mnt/etc/sysconfig/network-scripts/ifcfg-eth0 \
/mnt/etc/audit/audit.rules \
/mnt/etc/.updated \
/mnt/root/.bash_history

umount /mnt

# Clone the emplate into machine images

zfs snapshot tank/nbd/rpi-template@now

for i in rpi0 rpi1 rpi2 rpi3
do
	zfs clone tank/nbd/rpi-template@now tank/nbd/$i
	udevadm settle
	mount /dev/zvol/tank/nbd/$i /mnt
	rm -f /mnt/etc/machine-id
	systemd-firstboot --root=/mnt --timezone=Europe/Prague --setup-machine-id
	echo $i.base48.cz >/mnt/etc/hostname
	sed 's/=enforcing$/=permissive/' -i /mnt/etc/selinux/config
	echo >/mnt/etc/fstab <<EOF

EOF
	umount /mnt
done

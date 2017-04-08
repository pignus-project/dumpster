
RELEASE=25
PATCHLEVEL=$1

[ -t 0 ] && T="-t"

pimg () { koji --quiet -c pignus-koji.conf latest-pkg f$RELEASE-image $1 |awk '{print $1}' |
	xargs koji -c pignus-koji.conf buildinfo |tee /dev/stderr |sed -n 's,/mnt/koji\(.*sda\),http://koji.base48.cz/kojifiles\1,p'; }
ppub () { ssh $T root@pignus.computer "mkdir -p /data/pub/linux/pignus/releases/$RELEASE/images/ && wget -O /data/pub/linux/pignus/releases/$RELEASE/images/$1 $2"; }

PM=$(pimg Pignus)
PZ=$(pimg Pignus-Zero)

echo "pignus-image: $PM"
echo "pignus-image: $PZ"

if [ "$T" ]
then
	echo "CTRL+C to abort, ENTER to continue..."
	read
	echo "Proceeding to upload..."
fi

ppub pignus-minimal-$RELEASE$PATCHLEVEL.xz $PM
ppub pignus-zero-$RELEASE$PATCHLEVEL.xz $PZ

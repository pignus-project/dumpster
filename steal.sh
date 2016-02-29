#!/bin/bash

# Take a Fedora noarch package and import it to Pignus as it is
# source VCS url and optionally doing a scratch build
#
# Usage: USER=<user> steal.sh <NVR>

set -e
set -x

BUILDS=""
for P in "$@"
do
	[ "$P" ]

	NVR=$(koji -c fedora-koji.conf --quiet latest-pkg f23-updates $P |awk '{print $1}')
	[ "$NVR" ] || NVR="$P"

	rm -rf tmp
	mkdir -p tmp
	cd tmp
	koji -c fedora-koji.conf download-build $NVR
	cd ..
	find tmp -type f |egrep -v 'src.rpm|noarch.rpm' |grep . && exit 1 | :
	koji -c pignus-koji.conf import tmp/*.rpm
	BUILDS="$BUILDS $NVR"

	koji -c pignus-koji.conf add-pkg --owner $USER fedora-23-stolen $(rpm -qp --qf '%{name} ' tmp/*.src.rpm) || :
	rm -rf tmp
done

koji -c pignus-koji.conf tag-pkg fedora-23-stolen $BUILDS

#!/bin/bash

# Take a Fedora noarch package and import it to Pignus as it is
# source VCS url and optionally doing a scratch build
#
# Usage: steal.sh <NVR>

set -e
set -x

BUILDS=""
for P in "$@"
do
	[ "$P" ]

	pignus-koji --quiet latest-pkg f26 $P |grep fc26 && continue || :

	NVR=$(koji --quiet latest-pkg f26-updates $P |awk '{print $1}')
	[ "$NVR" ] || NVR="$P"

	rm -rf tmp
	mkdir -p tmp
	cd tmp
	koji download-build $NVR
	cd ..
	find tmp -type f |egrep -v 'src.rpm|noarch.rpm' |grep . && continue || :
	pignus-koji import tmp/*.rpm
	BUILDS="$BUILDS $NVR"

	rm -rf tmp
done

[ "$BUILDS" ] && pignus-koji tag-pkg --force f26-stolen $BUILDS

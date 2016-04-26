#!/bin/bash

# Get a Fedora package and build it into Pignus while figuring out the proper 
# source VCS url and optionally doing a scratch build
#
# Usage: USER=<user> propagate.sh <SRPM> | <NVR>|<N> [ ... : [ <NVR>|<N> ... [ : ...] ] ] 

set -e
set -x

[ "$TARGET" ] || TARGET=f23
BUILD=""
for P in "$@"
do
	[ "$P" ]

	# The chain build separator; leave it as it is
	if [ "$P" == ":" ]
	then
		BUILD="$BUILD :"
		continue
	fi

	# Maybe it's a <N>
	NVR=$(koji -c fedora-koji.conf --quiet latest-pkg f23-updates $P |awk '{print $1}')
	[ "$NVR" ] || NVR="$P"

	# Or it's a <NVR>
	URL=$(koji -c fedora-koji.conf buildinfo $NVR |sed -n 's,^Task:.*\, /\([^ :]*\):\([^ )]*\)),git://pkgs.fedoraproject.org/\1?#\2,p')
	[ "$URL" ] || URL="$P"

	if [ -f "$URL" ]
	then
		# Or it's a local SRPM
		N=$(rpm -qp --qf '%{name}' "$URL")
	else
		# Or a SRPM URI
		N=$(echo "$URL" |sed -n 's,.*/,,;s,^\([^/]*\)-[^-]*-[^-?]*$,\1,p;s,\([^?]*\)?#.*,\1,p')
	fi
	[ "$N" ]

	#NVR=$(koji -c pignus-koji.conf --quiet latest-pkg $TARGET $P |awk '{print $1}')

	T=$(koji -c pignus-koji.conf buildinfo $NVR |awk '/^State: COMPLETE/ {print $NF; exit} /^Task:/ {t=$2} END {print t}')
	if [ "$T" = COMPLETE ]
	then
		# Already built. Do a rebuild.
		T=""
		koji -c pignus-koji.conf build ${TARGET}_1 "$URL"
	else
		# Ensure the package is known
		koji -c pignus-koji.conf add-pkg --owner $USER $TARGET $N || :
		BUILD="$BUILD $URL"
	fi
done

[ "$BUILD" ] || exit 0
if echo $BUILD |grep -q ' '
then
	# Multiple packages to build
	koji -c pignus-koji.conf chain-build $TARGET $BUILD
else
	if [ "$T" ]
	then
		# A build was already attempted
		A=$(koji -c pignus-koji.conf resubmit $T |tee /dev/stderr |awk '/buildArch/ {print $1}' |tail -n1)
	else
		# A new build
		A=$(koji -c pignus-koji.conf build $TARGET $BUILD |tee /dev/stderr |awk '/buildArch/ {print $1}' |tail -n1)
	fi
	# Build status
	[ "$A" ] && koji -c pignus-koji.conf watch-logs --log=root.log $A |egrep 'No Package found|Package:|Requires:|Error:' 
fi

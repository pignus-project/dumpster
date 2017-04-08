#!/bin/bash

# Get a Fedora package and build it into Pignus while figuring out the proper 
# source VCS url and optionally doing a scratch build
#
# Usage: USER=<user> propagate.sh <SRPM> | <NVR>|<N> [ ... : [ <NVR>|<N> ... [ : ...] ] ] 

set -e
set -x

[ "$TARGET" ] || TARGET=f26
[ "$TAG" ] || TAG=$TARGET-updates
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
	NVR=$(koji --quiet latest-pkg $TAG $P |awk '{print $1}')
	[ "$NVR" ] || NVR="$P"

	# Or it's a <NVR>
	URL=$(koji buildinfo $NVR |sed -n 's,^Task:.*\, /\([^ :]*\):\([^ )]*\)),git://pkgs.fedoraproject.org/\1?#\2,p')
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

	#NVR=$(pignus-koji --quiet latest-pkg $TARGET $P |awk '{print $1}')

	T=$(pignus-koji buildinfo $NVR |awk '/^State: COMPLETE/ {print $NF; exit} /^Task:/ {t=$2} END {print t}')
	if [ "$T" = COMPLETE ]
	then
		# Already built. Do a rebuild.
		T=""
		#pignus-koji build $BUILDF ${TARGET}_1 "$URL"
		pignus-koji build $BUILDF ${TARGET} "$URL"
	else
		# Ensure the package is known
		pignus-koji add-pkg --owner $USER $TARGET $N || :
		BUILD="$BUILD $URL"
	fi
done

[ "$BUILD" ] || exit 0
if echo $BUILD |grep -q ' '
then
	# Multiple packages to build
	pignus-koji chain-build $TARGET $BUILD
else
	if [ "$T" ]
	then
		# A build was already attempted
		A=$(pignus-koji resubmit $T |tee /dev/stderr |awk '/buildArch/ {print $1}' |tail -n1)
	else
		# A new build
		A=$(pignus-koji build $BUILDF $TARGET $BUILD |tee /dev/stderr |awk '/buildArch/ {print $1}' |tail -n1)
	fi
	# Build status
	[ "$A" ] && pignus-koji watch-logs --log=root.log $A |egrep 'No Package found|Package:|Requires:|Error:|Warning:|No matching package|nothing provides|Cannot download' 
fi

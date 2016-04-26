#!/bin/bash

# Enqueue all builds that have been completed  for Fedora, but not for Pignus
#
# Usage: USER=<user> runall.sh

set -x
set -e

# What has been built for Pignus
koji -c pignus-koji.conf list-tagged --quiet --latest f23 |awk '{print $1}' >pignus.builds

# What has been built for Fedora
koji -c fedora-koji.conf list-tagged --quiet --inherit --latest f23-updates |awk '{print $1}' >fedora.builds

# What's missing
cat pignus.builds{,} fedora.builds  |sort |uniq -u >missing.builds

# Filter out what we *don't* want to automatically rebuild
for i in $(grep lr[0-9] pignus.builds |sed 's/-[^-]*-[^-]*$//')
do
	sed "/$i-[^-]*-[^-]*$/d" -i missing.builds
done

#cat missing.builds |
tac missing.builds |
while read i
do
	koji -c pignus-koji.conf add-pkg --owner $USER f23 $(echo $i |sed 's/-[^-]*-[^-]*$//')
	URL="$(koji -c fedora-koji.conf buildinfo $i |sed -n 's,^Task:.*\, /\([^ :]*\):\([^ )]*\)),git://pkgs.fedoraproject.org/\1?#\2,p')"
	koji -c pignus-koji.conf build --background --nowait f23 "$URL"
done

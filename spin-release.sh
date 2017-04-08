RELEASE=25
pignus-koji spin-appliance --nowait --ksurl 'git+https://github.com/pignus-project/pignus-kickstarts?#master' 'Pignus' $RELEASE f$RELEASE-image armv6hl pignus-minimal.ks
pignus-koji spin-appliance --nowait --ksurl 'git+https://github.com/pignus-project/pignus-kickstarts?#master' 'Pignus-Zero' $RELEASE f$RELEASE-image armv6hl pignus-zero.ks

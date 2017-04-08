pignus-koji add-tag f25 --parent=f24  --arches=armv6hl
pignus-koji add-tag f25-image --priority=0 --parent=f25  --arches=armv6hl
pignus-koji add-tag-inheritance --priority=10 --noconfig f25-image f24-image
pignus-koji add-tag f25-stolen --arches=armv6hl
pignus-koji add-tag-inheritance --noconfig f25 f25-stolen
pignus-koji add-tag f25-rebuild --arches=armv6hl
pignus-koji add-tag-inheritance --noconfig f25 f25-rebuild
pignus-koji regen-repo f25

pignus-koji add-target f25 f25 f25
pignus-koji add-target f25-candidate f25 f25
pignus-koji add-target f25-reuild f25-rebuild f25
pignus-koji add-target f25-image f25-image f25-image

pignus-koji remove-tag-inheritance rawhide f24
pignus-koji add-tag-inheritance rawhide f25
pignus-koji remove-tag-inheritance rawhide-image f24
pignus-koji add-tag-inheritance rawhide-image f25
pignus-koji remove-tag-inheritance rawhide-image f24-image
pignus-koji add-tag-inheritance --priority=0 --noconfig rawhide-image f25-image

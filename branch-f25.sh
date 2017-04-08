pignus-koji add-tag f25 --parent=f24  --arches=armv6hl
pignus-koji add-target f25-candidate f25 f25
pignus-koji add-target f25 f25 f25
pignus-koji add-target f25-image f25-image f25-image
pignus-koji add-tag f25-image --parent=f25  --arches=armv6hl
pignus-koji add-tag-inheritance --priority=10 --noconfig f25-image f24-image
pignus-koji regen-repo f25

pignus-koji remove-tag-inheritance rawhide f24
pignus-koji add-tag-inheritance rawhide f25
pignus-koji remove-tag-inheritance rawhide-image f24
pignus-koji add-tag-inheritance rawhide-image f25
pignus-koji remove-tag-inheritance rawhide-image f24-image
pignus-koji add-tag-inheritance --priority=10 --noconfig rawhide-image f25-image

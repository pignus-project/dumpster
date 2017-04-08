pignus-koji add-tag f26 --parent=f25  --arches=armv6hl
pignus-koji add-tag f26-image --priority=0 --parent=f26  --arches=armv6hl
pignus-koji add-tag-inheritance --priority=10 --noconfig f26-image f25-image
pignus-koji add-tag f26-stolen --arches=armv6hl
pignus-koji add-tag-inheritance --noconfig f26 f26-stolen
pignus-koji add-tag f26-rebuild --arches=armv6hl
pignus-koji add-tag-inheritance --noconfig f26 f26-rebuild
pignus-koji regen-repo f26

pignus-koji add-target f26 f26 f26
pignus-koji add-target f26-candidate f26 f26
pignus-koji add-target f26-rebuild f26-rebuild f26
pignus-koji add-target f26-image f26-image f26-image

pignus-koji remove-tag-inheritance rawhide f25
pignus-koji add-tag-inheritance rawhide f26
pignus-koji remove-tag-inheritance rawhide-image f25
pignus-koji add-tag-inheritance rawhide-image f26
pignus-koji remove-tag-inheritance rawhide-image f25-image
pignus-koji add-tag-inheritance --priority=0 --noconfig rawhide-image f26-image

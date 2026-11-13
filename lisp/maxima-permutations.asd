;;; maxima-permutations.asd — ASDF system definition for the permutations package

(defsystem "maxima-permutations"
  :description "Permutation groups for Maxima, built on cl-permutation"
  :version "0.1.0"
  :license "MIT"
  :depends-on ("cl-permutation")
  :serial t
  :components
  ((:file "handle")
   (:file "display")
   (:file "groups")
   (:file "perms")
   (:file "named")
   (:file "helpers")
   (:file "actions")
   (:file "homs")
   (:file "subgroups")
   (:file "series")))

;;; display.lisp — Maxima display and TeX for pgrp handles

(in-package :maxima)

(defun perm-group-summary (handle)
  (format nil "pgrp(degree ~D, ~D generators)"
          (perm-group-handle-degree handle)
          (cl-permutation:num-generators (perm-group-handle-group handle))))

(displa-def $pgrp dim-$pgrp)

(defun dim-$pgrp (form result)
  "Show a summary instead of the struct. Falls back to the generic display
   for unevaluated forms such as 'pgrp(x)."
  (let ((handle (cadr form)))
    (if (perm-group-handle-p handle)
        (dimension-string (makestring (perm-group-summary handle)) result)
        (dimension-function form result))))

(defprop $pgrp tex-perm-group tex)

(defun tex-perm-group (x l r)
  (let ((handle (cadr x)))
    (append l
            (list (if (perm-group-handle-p handle)
                      (format nil "\\text{pgrp(degree ~D, ~D generators)}"
                              (perm-group-handle-degree handle)
                              (cl-permutation:num-generators
                               (perm-group-handle-group handle)))
                      "\\text{pgrp}(\\ldots)"))
            r)))

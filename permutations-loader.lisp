;;; permutations-loader.lisp — Bootstrap Quicklisp and load the maxima-permutations system
;;; This file is loaded as Common Lisp from permutations.mac via load().

(in-package :maxima)

;; Bootstrap Quicklisp if available but not loaded
(unless (find-package :quicklisp)
  (let ((ql-init (merge-pathnames "quicklisp/setup.lisp"
                                  (user-homedir-pathname))))
    (if (probe-file ql-init)
        (load ql-init)
        (error "Quicklisp not found. Install it with: mxpm setup quicklisp"))))

;; Let ASDF find lisp/maxima-permutations.asd next to this file
(let ((here (make-pathname :directory (pathname-directory *load-truename*))))
  (pushnew (merge-pathnames "lisp/" here)
           asdf:*central-registry* :test #'equal))

;; Quicklisp resolves cl-permutation and its dependencies
(funcall (intern "QUICKLOAD" :ql) "maxima-permutations" :silent t)

;; Load the doc index for ? and ?? help (built by mxpm doc build), if present
(let* ((here (make-pathname :directory (pathname-directory *load-truename*)))
       (idx (merge-pathnames "permutations-index.lisp" here)))
  (when (probe-file idx)
    ($load (namestring idx))))

;;; handle.lisp — The pgrp opaque handle and permutation conversions

(in-package :maxima)

(defstruct (perm-group-handle
            (:constructor %make-perm-group-handle (group degree))
            (:print-function print-perm-group-handle))
  "An opaque handle wrapping a cl-permutation PERM-GROUP of the given degree."
  (group  nil :read-only t)
  (degree 0   :type fixnum :read-only t))

(defun print-perm-group-handle (obj stream depth)
  (declare (ignore depth))
  (format stream "#<pgrp degree ~D, ~D generators>"
          (perm-group-handle-degree obj)
          (cl-permutation:num-generators (perm-group-handle-group obj))))

(defun perm-group-form-p (x)
  "Is X a Maxima expression wrapping a pgrp handle?"
  (and (consp x)
       (consp (car x))
       (eq (caar x) '$pgrp)
       (perm-group-handle-p (cadr x))))

(defun $pgrp_p (x)
  "Predicate: is X a permutation group?"
  (perm-group-form-p x))

(defun perm-group-wrap (handle)
  `(($pgrp simp) ,handle))

(defun perm-group-unwrap (x fn)
  (unless (perm-group-form-p x)
    (merror "~M: expected a permutation group, got: ~M" fn x))
  (cadr x))

;;; Permutations cross the boundary as Maxima lists of images, the same
;;; form the combinatorics package uses: [2,1,3] maps 1 to 2, 2 to 1 and
;;; 3 to 3. cl-permutation's list-to-perm reads the same one-line form.

(defun perm-list-from-maxima (p fn)
  "Check that P is a Maxima list holding a permutation of 1..n and return it
   as a Lisp list."
  (when (perm-form-p p)
    (return-from perm-list-from-maxima (copy-list (perm-handle-images (cadr p)))))
  (unless ($listp p)
    (merror "~M: expected a permutation as a list of images, got: ~M" fn p))
  (let ((l (cdr p)))
    (unless (and (every #'integerp l)
                 (equal (sort (copy-list l) #'<)
                        (loop :for i :from 1 :to (length l) :collect i)))
      (merror "~M: ~M is not a permutation of 1, ..., ~M" fn p (length l)))
    l))

(defun perm-list-fit (l n)
  "Pad the permutation list L with fixed points up to degree N, or drop
   trailing fixed points down to N. Return NIL if L moves a point above N."
  (let ((size (length l)))
    (cond ((<= size n)
           (append l (loop :for i :from (1+ size) :to n :collect i)))
          ((loop :for i :from (1+ n) :to size
                 :always (= (nth (1- i) l) i))
           (subseq l 0 n))
          (t nil))))

(defun perm-to-maxima (perm)
  (perm-out (cl-permutation:perm-to-list perm)))

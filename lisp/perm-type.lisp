;;; perm-type.lisp — pgrp_perm, a permutation shown in cycle notation
;;;
;;; A permutation is wrapped as (($pgrp_perm simp) #<handle>). Handles are
;;; interned by their image list, so equal permutations of the same degree
;;; share one handle and = and member work. The degree is kept: (1 2) in S_4
;;; has cycle type [2, 1, 1]. pgrp_eq compares across degrees, and plain
;;; lists are accepted wherever a permutation is. Permutation results are
;;; pgrp_perm values unless pgrp_perm_output is false.

(in-package :maxima)

(defmvar $pgrp_perm_output t
  "When true (the default), permutation results are pgrp_perm values shown in
   cycle notation; when false, they are lists of images.")

(defstruct (perm-handle
            (:constructor %make-perm-handle (images))
            (:print-function (lambda (obj stream depth)
                               (declare (ignore depth))
                               (format stream "#<pgrp_perm ~A>" (perm-handle-images obj)))))
  (images nil :read-only t))

(defvar *perm-handles* (make-hash-table :test #'equal))

(defun intern-perm (l)
  (or (gethash l *perm-handles*)
      (setf (gethash l *perm-handles*) (%make-perm-handle (copy-list l)))))

(defun perm-form-p (x)
  (and (consp x) (consp (car x)) (eq (caar x) '$pgrp_perm) (perm-handle-p (cadr x))))

(defun perm-wrap (l)
  `(($pgrp_perm simp) ,(intern-perm l)))

(defun perm-out (l)
  "A permutation result: a pgrp_perm when pgrp_perm_output is true, else a list."
  (if $pgrp_perm_output (perm-wrap l) (cons '(mlist simp) l)))

(defun $pgrp_perm_p (x) (perm-form-p x))

(defun $pgrp_perm (p)
  "The permutation with image list p as a pgrp_perm."
  (if (perm-handle-p p)
      `(($pgrp_perm simp) ,p)
      (perm-wrap (perm-list-from-maxima p '$pgrp_perm))))

(defun $pgrp_apply (p i)
  "The image of the point i under p. Points past the end are fixed."
  (unless (and (integerp i) (>= i 1))
    (merror "pgrp_apply: expected a positive integer point, got: ~M" i))
  (let ((l (perm-list-from-maxima p '$pgrp_apply)))
    (if (<= i (length l)) (nth (1- i) l) i)))

(defun $pgrp_eq (p q)
  "Are p and q the same permutation? Either may be a pgrp_perm or a list,
   and a shorter one counts as fixing the extra points."
  (let ((a (perm-list-from-maxima p '$pgrp_eq))
        (b (perm-list-from-maxima q '$pgrp_eq)))
    (let ((n (max (length a) (length b))))
      (equal (perm-list-fit a n) (perm-list-fit b n)))))

(defun $pgrp_support (p)
  "The points p moves, in increasing order."
  (cons '(mlist simp)
        (loop :for image :in (perm-list-from-maxima p '$pgrp_support)
              :for i :from 1
              :unless (= image i) :collect i)))

(defun $pgrp_sort (l)
  "The permutations in the list l (pgrp_perm values or lists) sorted by their
   image lists, padded to a common degree. Each keeps its own form."
  (unless ($listp l)
    (merror "pgrp_sort: expected a list of permutations, got: ~M" l))
  (let* ((items (mapcar (lambda (p) (cons (perm-list-from-maxima p '$pgrp_sort) p)) (cdr l)))
         (n (reduce #'max items :key (lambda (it) (length (car it))) :initial-value 1)))
    (cons '(mlist simp)
          (mapcar #'cdr (stable-sort items #'perm-list<
                                     :key (lambda (it) (perm-list-fit (car it) n)))))))

(defun $pgrp_perm_list (p &optional n)
  "p as a list of images, padded with fixed points to length n if given."
  (let ((l (perm-list-from-maxima p '$pgrp_perm_list)))
    (cons '(mlist simp)
          (if n
              (or (perm-list-fit l n)
                  (merror "pgrp_perm_list: ~M moves a point above ~M" p n))
              l))))

;;; string() and grind print pgrp_perm([images]), which reads back as the
;;; same permutation.

(defprop $pgrp_perm msize-pgrp-perm grind)

(defun msize-pgrp-perm (x l r)
  (let ((h (cadr x)))
    (msize-function (if (perm-handle-p h)
                        `(($pgrp_perm simp) ((mlist simp) ,@(perm-handle-images h)))
                        x)
                    l r nil)))

;;; Display: cycle notation, () for the identity

(defun perm-cycle-string (l &optional tex)
  (let ((cycles (perm-list-cycles l)))
    (if (null cycles)
        "()"
        (format nil (if tex "~{\\left(~{~A~^\\ ~}\\right)~}" "~{(~{~A~^ ~})~}") cycles))))

(displa-def $pgrp_perm dim-$pgrp_perm)

(defun dim-$pgrp_perm (form result)
  (let ((h (cadr form)))
    (if (perm-handle-p h)
        (dimension-string (makestring (perm-cycle-string (perm-handle-images h))) result)
        (dimension-function form result))))

(defprop $pgrp_perm tex-pgrp-perm tex)

(defun tex-pgrp-perm (x l r)
  (let ((h (cadr x)))
    (append l (list (if (perm-handle-p h)
                        (perm-cycle-string (perm-handle-images h) t)
                        "\\text{pgrp\\_perm}(\\ldots)"))
            r)))

;;; perms.lisp — Single permutations: composition, cycles, order, sign
;;;
;;; These work on image lists directly. Composition reads right to left, as
;;; in Dummit and Foote §1.3: pgrp_compose(s, t) is s∘t, which applies t
;;; first. (The combinatorics package's permult(p, q) applies p first.)

(in-package :maxima)

(defun perm-list-identity (n)
  (loop :for i :from 1 :to n :collect i))

(defun perm-list-compose (s tt)
  "s∘tt as lists: apply TT, then S. Pads the shorter one with fixed points."
  (let* ((n (max (length s) (length tt)))
         (s (perm-list-fit s n))
         (tt (perm-list-fit tt n)))
    (loop :for i :in tt :collect (nth (1- i) s))))

(defun perm-list-inverse (p)
  (let ((inv (make-list (length p))))
    (loop :for image :in p
          :for i :from 1
          :do (setf (nth (1- image) inv) i))
    inv))

(defun perm-list-power (p k)
  (let ((base (if (minusp k) (perm-list-inverse p) p))
        (result (perm-list-identity (length p))))
    (dotimes (i (abs k) result)
      (setf result (perm-list-compose base result)))))

(defun perm-list-cycles (p)
  "Disjoint cycles of P, 1-cycles left out. Each cycle starts at its least
   point and cycles come in order of least point, as in D&F §1.3."
  (let ((seen (make-array (1+ (length p)) :initial-element nil))
        (cycles '()))
    (loop :for start :from 1 :to (length p)
          :unless (aref seen start)
            :do (let ((cycle (loop :for i := start :then (nth (1- i) p)
                                   :until (and (/= i start) (aref seen i))
                                   :do (setf (aref seen i) t)
                                   :collect i
                                   :until (= (nth (1- i) p) start))))
                  (when (> (length cycle) 1)
                    (push cycle cycles))))
    (nreverse cycles)))

(defun perm-list-cycle-lengths (p)
  "Lengths of all cycles of P, 1-cycles included."
  (let ((moved (perm-list-cycles p)))
    (append (mapcar #'length moved)
            (make-list (- (length p) (reduce #'+ moved :key #'length))
                       :initial-element 1))))

(defun $pgrp_compose (&rest perms)
  "pgrp_compose(s, t) is s∘t: apply t first, then s. With more arguments,
   pgrp_compose(a, b, c) is a∘b∘c, so c applies first."
  (when (null perms)
    (merror "pgrp_compose: needs at least one permutation"))
  (let ((lists (mapcar (lambda (p) (perm-list-from-maxima p '$pgrp_compose)) perms)))
    (cons '(mlist simp)
          (reduce #'perm-list-compose lists :from-end t))))

(defun $pgrp_inverse (p)
  (cons '(mlist simp)
        (perm-list-inverse (perm-list-from-maxima p '$pgrp_inverse))))

(defun $pgrp_power (p k)
  "p composed with itself k times; k may be negative or zero."
  (unless (integerp k)
    (merror "pgrp_power: the exponent must be an integer, got: ~M" k))
  (cons '(mlist simp)
        (perm-list-power (perm-list-from-maxima p '$pgrp_power) k)))

(defun $pgrp_identity (n)
  (unless (and (integerp n) (>= n 1))
    (merror "pgrp_identity: the degree must be a positive integer, got: ~M" n))
  (cons '(mlist simp) (perm-list-identity n)))

(defun $pgrp_cycles (p)
  "The disjoint cycle decomposition of p, without 1-cycles. The identity
   gives []."
  (cons '(mlist simp)
        (mapcar (lambda (c) (cons '(mlist simp) c))
                (perm-list-cycles (perm-list-from-maxima p '$pgrp_cycles)))))

(defun cycle-list-from-maxima (c fn)
  (unless (and ($listp c)
               (cdr c)
               (every (lambda (x) (and (integerp x) (plusp x))) (cdr c))
               (= (length (cdr c))
                  (length (remove-duplicates (cdr c)))))
    (merror "~M: ~M is not a cycle of distinct positive integers" fn c))
  (cdr c))

(defun cycle-to-perm-list (c n)
  (let ((p (perm-list-identity n)))
    (loop :for (from to) :on (append c (list (first c)))
          :while to
          :do (setf (nth (1- from) p) to))
    p))

(defun $pgrp_from_cycles (cycles &optional n)
  "The permutation written by the list of cycles, read as a product right
   to left: pgrp_from_cycles([[1,2],[1,3]]) is (1 2)∘(1 3). The degree is n
   if given, else the largest point mentioned."
  (unless ($listp cycles)
    (merror "pgrp_from_cycles: expected a list of cycles, got: ~M" cycles))
  (let* ((cs (mapcar (lambda (c) (cycle-list-from-maxima c '$pgrp_from_cycles))
                     (cdr cycles)))
         (top (reduce #'max (mapcar (lambda (c) (reduce #'max c)) cs) :initial-value 1))
         (deg (or n top)))
    (unless (and (integerp deg) (>= deg top))
      (merror "pgrp_from_cycles: the degree must be an integer at least ~M, got: ~M" top deg))
    (cons '(mlist simp)
          (reduce #'perm-list-compose
                  (mapcar (lambda (c) (cycle-to-perm-list c deg)) cs)
                  :from-end t
                  :initial-value (perm-list-identity deg)))))

(defun $pgrp_element_order (p)
  "The order of the permutation p: the lcm of its cycle lengths."
  (reduce #'lcm (perm-list-cycle-lengths (perm-list-from-maxima p '$pgrp_element_order))
          :initial-value 1))

(defun $pgrp_sign (p)
  "1 for an even permutation, -1 for an odd one."
  (let ((cycles (perm-list-cycles (perm-list-from-maxima p '$pgrp_sign))))
    (if (evenp (reduce #'+ cycles :key (lambda (c) (1- (length c))))) 1 -1)))

(defun $pgrp_cycle_type (p)
  "The lengths of the cycles of p, 1-cycles included, largest first. They
   add up to the length of p."
  (cons '(mlist simp)
        (sort (perm-list-cycle-lengths (perm-list-from-maxima p '$pgrp_cycle_type)) #'>)))

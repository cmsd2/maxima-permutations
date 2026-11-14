;;; homs.lisp — Homomorphisms between permutation groups, and isomorphism tests
;;;
;;; A homomorphism is given by the images of the source's generators. Its
;;; table of values is built by walking out from the identity: if x is known
;;; and s is a generator with image t, then s∘x maps to t∘phi(x). Any clash
;;; means the images don't define a homomorphism.

(in-package :maxima)

(defstruct (perm-hom
            (:constructor %make-perm-hom (source target table))
            (:print-function (lambda (obj stream depth)
                               (declare (ignore depth))
                               (format stream "#<pgrp_hom degree ~D to degree ~D>"
                                       (perm-group-handle-degree (perm-hom-source obj))
                                       (perm-group-handle-degree (perm-hom-target obj))))))
  (source nil :read-only t)
  (target nil :read-only t)
  (table  nil :read-only t))

(defun perm-hom-form-p (x)
  (and (consp x) (consp (car x)) (eq (caar x) '$pgrp_hom) (perm-hom-p (cadr x))))

(defun $pgrp_hom_p (x) (perm-hom-form-p x))

(defun perm-hom-unwrap (x fn)
  (unless (perm-hom-form-p x)
    (merror "~M: expected a homomorphism made by pgrp_hom, got: ~M" fn x))
  (cadr x))

(defun build-hom-table (gens images source-degree target-degree)
  "The table of a homomorphism sending GENS to IMAGES, or NIL if the images
   don't define one."
  (let ((table (make-hash-table :test #'equal))
        (start (perm-list-identity source-degree)))
    (setf (gethash start table) (perm-list-identity target-degree))
    (let ((frontier (list start)))
      (loop :while frontier
            :do (let ((new '()))
                  (dolist (x frontier)
                    (loop :for s :in gens :for img :in images
                          :for y := (perm-list-compose s x)
                          :for value := (perm-list-compose img (gethash x table))
                          :do (multiple-value-bind (old found) (gethash y table)
                                (cond ((not found)
                                       (setf (gethash y table) value)
                                       (push y new))
                                      ((not (equal old value))
                                       (return-from build-hom-table nil))))))
                  (setf frontier new))))
    table))

(defun perm-hom-make (src tgt images fn)
  (let ((table (build-hom-table (perm-group-generator-lists src) images
                               (perm-group-handle-degree src)
                               (perm-group-handle-degree tgt))))
    (unless table
      (merror "~M: these images do not define a homomorphism" fn))
    (%make-perm-hom src tgt table)))

(defun $pgrp_hom (g h images)
  "The homomorphism from g to h sending the generators of g, in the order
   pgrp_generators(g) lists them, to images. Fails if no homomorphism does
   that."
  (let* ((src (perm-group-unwrap g '$pgrp_hom))
         (tgt (perm-group-unwrap h '$pgrp_hom))
         (gens (perm-group-generator-lists src)))
    (unless (and ($listp images) (= (length (cdr images)) (length gens)))
      (merror "pgrp_hom: expected ~M images, one for each of pgrp_generators(g), got: ~M"
              (length gens) images))
    (let ((imgs (mapcar (lambda (p) (perm-list-at-degree p (perm-group-handle-degree tgt) '$pgrp_hom))
                        (cdr images))))
      (dolist (l imgs)
        (unless (perm-group-member-list-p l tgt)
          (merror "pgrp_hom: the image ~M is not in the target group" (cons '(mlist simp) l))))
      (when (> (cl-permutation:group-order (perm-group-handle-group src)) $pgrp_max_elements)
        (merror "pgrp_hom: the source has more than pgrp_max_elements = ~M elements"
                $pgrp_max_elements))
      `(($pgrp_hom simp) ,(perm-hom-make src tgt imgs '$pgrp_hom)))))

(defun $pgrp_hom_apply (phi p)
  "The image of the permutation p under the homomorphism phi."
  (let* ((f (perm-hom-unwrap phi '$pgrp_hom_apply))
         (l (perm-list-at-degree p (perm-group-handle-degree (perm-hom-source f)) '$pgrp_hom_apply)))
    (multiple-value-bind (value found) (gethash l (perm-hom-table f))
      (unless found
        (merror "pgrp_hom_apply: ~M is not in the source group" p))
      (cons '(mlist simp) value))))

(defun perm-hom-sources-where (f pred)
  (loop :for k :being :the :hash-keys :of (perm-hom-table f) :using (hash-value v)
        :when (funcall pred v) :collect k))

(defun $pgrp_kernel (phi)
  "The kernel of phi: the elements that map to the identity."
  (let* ((f (perm-hom-unwrap phi '$pgrp_kernel))
         (id (perm-list-identity (perm-group-handle-degree (perm-hom-target f)))))
    (perm-group-wrap
     (perm-group-from-lists (sort (perm-hom-sources-where f (lambda (v) (equal v id))) #'perm-list<)
                            (perm-group-handle-degree (perm-hom-source f)) '$pgrp_kernel))))

(defun $pgrp_image (phi)
  "The image of phi, a subgroup of its target."
  (let ((f (perm-hom-unwrap phi '$pgrp_image)))
    (perm-group-wrap
     (perm-group-from-lists
      (sort (remove-duplicates (loop :for v :being :the :hash-values :of (perm-hom-table f) :collect v)
                               :test #'equal)
            #'perm-list<)
      (perm-group-handle-degree (perm-hom-target f)) '$pgrp_image))))

(defun $pgrp_preimage (phi k)
  "The elements of the source that phi maps into the group k."
  (let* ((f (perm-hom-unwrap phi '$pgrp_preimage))
         (hk (perm-group-unwrap k '$pgrp_preimage)))
    (perm-group-wrap
     (perm-group-from-lists (sort (perm-hom-sources-where f (lambda (v) (perm-group-member-list-p v hk)))
                                  #'perm-list<)
                            (perm-group-handle-degree (perm-hom-source f)) '$pgrp_preimage))))

;;; Isomorphism by search: map a small generating set of g to elements of h
;;; of the same orders, and keep the first assignment that gives a bijective
;;; homomorphism. Fine for textbook-sized groups.

(defun small-generating-set (h fn)
  "A short list of generators of H, picking elements of large order first."
  (let* ((n (perm-group-handle-degree h))
         (elements (sort (copy-list (perm-group-element-lists h fn)) #'>
                         :key #'perm-list-element-order))
         (gens '()) (current nil))
    (dolist (l elements)
      (when (and current (= (cl-permutation:group-order (perm-group-handle-group current))
                            (cl-permutation:group-order (perm-group-handle-group h))))
        (return))
      (unless (or (equal l (perm-list-identity n))
                  (and current (perm-group-member-list-p l current)))
        (setf gens (append gens (list l))
              current (perm-group-make gens fn))))
    (or gens (list (perm-list-identity n)))))

(defun order-profile (elements)
  (sort (mapcar #'perm-list-element-order elements) #'<))

(defun perm-group-isomorphism (g h fn)
  "A homomorphism struct from G to H that is a bijection, or NIL."
  (let ((eg (perm-group-element-lists g fn))
        (eh (perm-group-element-lists h fn)))
    (unless (and (= (length eg) (length eh))
                 (equal (order-profile eg) (order-profile eh)))
      (return-from perm-group-isomorphism nil))
    (let* ((gens (small-generating-set g fn))
           (src (perm-group-make gens fn))
           (candidates (mapcar (lambda (s)
                                 (remove-if-not (lambda (e) (= (perm-list-element-order e)
                                                               (perm-list-element-order s)))
                                                eh))
                               gens))
           (n (length eg)))
      (labels ((try (chosen remaining)
                 (if (null remaining)
                     (let* ((imgs (reverse chosen))
                            (table (build-hom-table gens imgs (perm-group-handle-degree g)
                                                   (perm-group-handle-degree h))))
                       (when (and table
                                  (= (length (remove-duplicates
                                              (loop :for v :being :the :hash-values :of table :collect v)
                                              :test #'equal))
                                     n))
                         (return-from perm-group-isomorphism
                           (%make-perm-hom src h table))))
                     (dolist (c (first remaining))
                       (try (cons c chosen) (rest remaining))))))
        (try '() candidates)
        nil))))

(defun $pgrp_isomorphism (g h)
  "An isomorphism from g to h as a pgrp_hom on a small generating set of g,
   or false if the groups are not isomorphic. Searches, so keep the groups
   small."
  (let* ((hg (perm-group-unwrap g '$pgrp_isomorphism))
         (hh (perm-group-unwrap h '$pgrp_isomorphism))
         (iso (perm-group-isomorphism hg hh '$pgrp_isomorphism)))
    (if iso `(($pgrp_hom simp) ,iso) nil)))

(defun $pgrp_isomorphic_p (g h)
  "Are the groups g and h isomorphic?"
  (and ($pgrp_isomorphism g h) t))

;;; Display

(displa-def $pgrp_hom dim-$pgrp_hom)

(defun dim-$pgrp_hom (form result)
  (let ((f (cadr form)))
    (if (perm-hom-p f)
        (dimension-string (makestring (format nil "pgrp_hom(degree ~D to degree ~D)"
                                              (perm-group-handle-degree (perm-hom-source f))
                                              (perm-group-handle-degree (perm-hom-target f))))
                          result)
        (dimension-function form result))))

(defprop $pgrp_hom tex-perm-hom tex)

(defun tex-perm-hom (x l r)
  (let ((f (cadr x)))
    (append l
            (list (if (perm-hom-p f)
                      (format nil "\\text{pgrp\\_hom(degree ~D to degree ~D)}"
                              (perm-group-handle-degree (perm-hom-source f))
                              (perm-group-handle-degree (perm-hom-target f)))
                      "\\text{pgrp\\_hom}(\\ldots)"))
            r)))

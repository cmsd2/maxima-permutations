;;; graphs.lisp — Cayley graphs and a spectral layout for drawing them
;;;
;;; pgrp_cayley_graph returns plain Maxima lists, [n, edges], so a plotting
;;; package can draw it without knowing about this one. pgrp_spectral_layout
;;; places the vertices of such a graph using eigenvectors of its Laplacian.

(in-package :maxima)

(defun perm-list-involution-p (s)
  (equal (perm-list-compose s s) (perm-list-identity (length s))))

(defun $pgrp_cayley_graph (g &optional gens)
  "pgrp_cayley_graph(G) or pgrp_cayley_graph(G, gens): the Cayley graph of
   G for the generators of G, or for the permutations gens. Returns
   [n, edges]: n vertices, vertex i being the i-th element of
   pgrp_elements(G), and edges [i, j, k] joining g_i to g_i∘s_k, where s_k
   is the k-th generator. A generator of order 2 gives each edge once."
  (let* ((fn '$pgrp_cayley_graph)
         (h (perm-group-unwrap g fn))
         (n (perm-group-handle-degree h))
         (elements (perm-group-element-lists h fn))
         (gen-lists (if gens
                        (generator-lists-at-degree gens n fn)
                        (perm-group-generator-lists h)))
         (index (make-hash-table :test #'equal))
         (edges '()))
    (when (null gen-lists)
      (merror "~M: needs at least one generator" fn))
    (dolist (s gen-lists)
      (unless (perm-group-member-list-p s h)
        (merror "~M: ~M is not an element of the group" fn (perm-out s))))
    (loop :for e :in elements :for i :from 1 :do (setf (gethash e index) i))
    (loop :for s :in gen-lists
          :for k :from 1
          :for involution := (perm-list-involution-p s)
          :unless (equal s (perm-list-identity n))
            :do (loop :for e :in elements
                      :for i :from 1
                      :for j := (gethash (perm-list-compose e s) index)
                      :unless (and involution (> i j))
                        :do (push (list '(mlist simp) i j k) edges)))
    (list '(mlist simp)
          (length elements)
          (cons '(mlist simp) (nreverse edges)))))

;;; The symmetric eigenproblem, by cyclic Jacobi rotations. Fine for the
;;; graphs of groups with up to a few hundred elements.

(defun jacobi-eigen (a n)
  "Eigenvalues and eigenvectors of the symmetric N×N double-float array A,
   which is overwritten. Returns (values eigenvalues vectors): eigenvalues a
   vector, and the eigenvector for eigenvalue i in column i of VECTORS."
  (declare (type (simple-array double-float (* *)) a) (type fixnum n))
  (let ((v (make-array (list n n) :element-type 'double-float :initial-element 0d0)))
    (dotimes (i n) (setf (aref v i i) 1d0))
    (let ((scale (max 1d0 (loop :for i :below n :maximize (abs (aref a i i))))))
      (loop :for sweep :from 1 :to 100
            :for off := (loop :for p :below n
                              :sum (loop :for q :from (1+ p) :below n
                                         :sum (expt (aref a p q) 2)))
            :until (< off (* 1d-26 scale scale))
            :do (dotimes (p n)
                  (loop :for q :from (1+ p) :below n
                        :for apq := (aref a p q)
                        :unless (< (abs apq) (* 1d-300 scale))
                          :do (let* ((theta (/ (- (aref a q q) (aref a p p)) (* 2d0 apq)))
                                     (tt (/ (if (>= theta 0d0) 1d0 -1d0)
                                            (+ (abs theta) (sqrt (+ (* theta theta) 1d0)))))
                                     (c (/ 1d0 (sqrt (+ (* tt tt) 1d0))))
                                     (s (* tt c)))
                                ;; A ← AP, then A ← PᵀA, V ← VP
                                (dotimes (k n)
                                  (let ((akp (aref a k p)) (akq (aref a k q)))
                                    (setf (aref a k p) (- (* c akp) (* s akq))
                                          (aref a k q) (+ (* s akp) (* c akq)))))
                                (dotimes (k n)
                                  (let ((apk (aref a p k)) (aqk (aref a q k)))
                                    (setf (aref a p k) (- (* c apk) (* s aqk))
                                          (aref a q k) (+ (* s apk) (* c aqk)))))
                                (dotimes (k n)
                                  (let ((vkp (aref v k p)) (vkq (aref v k q)))
                                    (setf (aref v k p) (- (* c vkp) (* s vkq))
                                          (aref v k q) (+ (* s vkp) (* c vkq))))))))))
    (let ((values (make-array n :element-type 'double-float)))
      (dotimes (i n) (setf (aref values i) (aref a i i)))
      (values values v))))

(defmvar $pgrp_spectral_max_vertices 1000
  "pgrp_spectral_layout refuses graphs with more vertices than this.")

(defun cayley-graph-parts (c fn)
  "The vertex count and the edges [i, j, ...] of the graph value C."
  (unless (and ($listp c) (= (length (cdr c)) 2)
               (integerp (second c)) ($listp (third c)))
    (merror "~M: expected [n, edges], as pgrp_cayley_graph returns, got: ~M" fn c))
  (let ((n (second c))
        (edges (mapcar (lambda (e)
                         (unless (and ($listp e) (>= (length (cdr e)) 2)
                                      (integerp (second e)) (integerp (third e)))
                           (merror "~M: expected an edge [i, j] or [i, j, k], got: ~M" fn e))
                         (list (second e) (third e)))
                       (cdr (third c)))))
    (dolist (e edges)
      (unless (and (<= 1 (first e) n) (<= 1 (second e) n))
        (merror "~M: edge ~M names a vertex outside 1, ..., ~M" fn
                (cons '(mlist simp) e) n)))
    (values n edges)))

(defun eigenvalue-groups (sorted tol)
  "The sizes of the runs of equal values (within TOL) in the sorted list."
  (let ((sizes '()) (prev nil))
    (dolist (x sorted (nreverse sizes))
      (if (and prev (< (- x prev) tol))
          (incf (car sizes))
          (push 1 sizes))
      (setf prev x))))

(defun $pgrp_spectral_layout (c &optional (dim 3))
  "pgrp_spectral_layout(C) or pgrp_spectral_layout(C, dim): a point in dim
   dimensions (3 by default) for each vertex of the graph C = [n, edges],
   from the eigenvectors of its Laplacian for the dim lowest eigenvalues
   above zero. The points are scaled so the furthest is 1 from the origin."
  (let ((fn '$pgrp_spectral_layout))
    (unless (and (integerp dim) (>= dim 1))
      (merror "~M: expected a positive dimension, got: ~M" fn dim))
    (multiple-value-bind (n edges) (cayley-graph-parts c fn)
      (when (> n $pgrp_spectral_max_vertices)
        (merror "~M: the graph has ~M vertices, more than pgrp_spectral_max_vertices = ~M"
                fn n $pgrp_spectral_max_vertices))
      (when (> (1+ dim) n)
        (merror "~M: a graph with ~M vertices has no ~M-dimensional layout" fn n dim))
      (let ((lap (make-array (list n n) :element-type 'double-float :initial-element 0d0)))
        (dolist (e edges)
          (destructuring-bind (i j) (mapcar #'1- e)
            (unless (= i j)
              (decf (aref lap i j) 1d0)
              (decf (aref lap j i) 1d0)
              (incf (aref lap i i) 1d0)
              (incf (aref lap j j) 1d0))))
        (multiple-value-bind (vals vecs) (jacobi-eigen lap n)
          (let* ((order (sort (loop :for i :below n :collect i) #'< :key (lambda (i) (aref vals i))))
                 (sorted (mapcar (lambda (i) (aref vals i)) order))
                 (tol (* 1d-7 (max 1d0 (car (last sorted)))))
                 (groups (eigenvalue-groups sorted tol)))
            (unless (= (first groups) 1)
              (merror "~M: the graph is not connected (it has ~M parts); the generators don't generate the group"
                      fn (first groups)))
            ;; dim must take whole groups of equal eigenvalues, or the layout
            ;; depends on an arbitrary choice of vectors within a group
            (let ((ends (loop :for size :in (rest groups)
                              :sum size :into total
                              :collect total)))
              (unless (member dim ends)
                (merror "~M: the lowest eigenvalues above zero come in groups of ~M, so dim must be one of ~M"
                        fn
                        (cons '(mlist simp) (subseq (rest groups) 0 (min 6 (length (rest groups)))))
                        (cons '(mlist simp) (subseq ends 0 (min 6 (length ends)))))))
            (let* ((cols (subseq order 1 (1+ dim)))
                   (points (loop :for i :below n
                                 :collect (mapcar (lambda (col) (aref vecs i col)) cols)))
                   (radius (loop :for p :in points
                                 :maximize (sqrt (reduce #'+ (mapcar (lambda (x) (* x x)) p))))))
              (cons '(mlist simp)
                    (mapcar (lambda (p)
                              (cons '(mlist simp) (mapcar (lambda (x) (/ x radius)) p)))
                            points)))))))))

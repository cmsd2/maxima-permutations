;;; actions.lisp — Groups from actions, orbits, stabilisers, counting, Cayley's theorem

(in-package :maxima)

(defun action-perm-list (g points act fn)
  "The permutation of POINTS (a Lisp list of Maxima objects) that G induces
   under ACT, as a list of indexes: entry i is the position of act(g, x_i)."
  (let ((images (loop :for x :in points
                      :for y := (mapply act (list g x) act)
                      :collect (or (position y points :test #'alike1)
                                   (merror "~M: act(~M, ~M) = ~M is not one of the points"
                                           fn g x y)))))
    (unless (= (length (remove-duplicates images)) (length images))
      (merror "~M: ~M does not act as a permutation of the points" fn g))
    (mapcar #'1+ images)))

(defun points-from-maxima (points fn)
  (unless (and ($listp points) (cdr points))
    (merror "~M: expected a non-empty list of points, got: ~M" fn points))
  (cdr points))

(defun $pgrp_action_perm (g points act)
  "The permutation of points that g induces: entry i is the position of
   act(g, points[i]) in points."
  (cons '(mlist simp)
        (action-perm-list g (points-from-maxima points '$pgrp_action_perm) act
                          '$pgrp_action_perm)))

(defun $pgrp_from_action (gens points act)
  "The permutation group on 1, ..., length(points) induced by the generators
   gens acting on points through act(g, x). Point i stands for points[i].
   gens can be anything act accepts: matrices, permutations, symbols."
  (unless ($listp gens)
    (merror "pgrp_from_action: expected a list of generators, got: ~M" gens))
  (let ((pts (points-from-maxima points '$pgrp_from_action)))
    (perm-group-wrap
     (perm-group-make (or (mapcar (lambda (g) (action-perm-list g pts act '$pgrp_from_action))
                                  (cdr gens))
                          (list (perm-list-identity (length pts))))
                      '$pgrp_from_action))))

(defun point-arg (x n fn)
  (unless (and (integerp x) (<= 1 x n))
    (merror "~M: expected a point between 1 and ~M, got: ~M" fn n x))
  x)

(defun $pgrp_orbit (g x)
  "The orbit of the point x under the group g, sorted."
  (let* ((h (perm-group-unwrap g '$pgrp_orbit))
         (gens (perm-group-generator-lists h))
         (orbit (list (point-arg x (perm-group-handle-degree h) '$pgrp_orbit)))
         (frontier orbit))
    (loop :while frontier
          :do (let ((new '()))
                (dolist (y frontier)
                  (dolist (s gens)
                    (let ((z (nth (1- y) s)))
                      (unless (member z orbit)
                        (push z orbit)
                        (push z new)))))
                (setf frontier new)))
    (cons '(mlist simp) (sort orbit #'<))))

(defun $pgrp_stabiliser (g x)
  "The subgroup of g fixing the point x."
  (let* ((h (perm-group-unwrap g '$pgrp_stabiliser))
         (n (perm-group-handle-degree h)))
    (point-arg x n '$pgrp_stabiliser)
    (perm-group-wrap
     (perm-group-from-lists (remove-if-not (lambda (l) (= (nth (1- x) l) x))
                                           (perm-group-element-lists h '$pgrp_stabiliser))
                            n '$pgrp_stabiliser))))

(defun perm-list-cycle-count (l)
  "Number of cycles of L, fixed points included."
  (length (perm-list-cycle-lengths l)))

(defun $pgrp_count_orbits (g k)
  "The number of ways to colour the points with k colours, counting two
   colourings as the same when an element of g turns one into the other.
   Burnside's lemma: the average over g of k^(number of cycles)."
  (let* ((h (perm-group-unwrap g '$pgrp_count_orbits))
         (elements (perm-group-element-lists h '$pgrp_count_orbits)))
    (div (addn (mapcar (lambda (l) (power k (perm-list-cycle-count l))) elements) t)
         (length elements))))

(defun $pgrp_cycle_index (g &optional (var '$x))
  "The cycle index of g: the average over g of the product of x[k]^m_k, where
   m_k is the number of k-cycles. Substituting x[k] = c_1^k + ... + c_r^k
   counts colourings with r colours by how often each colour is used."
  (let* ((h (perm-group-unwrap g '$pgrp_cycle_index))
         (elements (perm-group-element-lists h '$pgrp_cycle_index))
         (counts (make-hash-table :test #'equal)))
    (dolist (l elements)
      (incf (gethash (sort (perm-list-cycle-lengths l) #'<) counts 0)))
    (let ((terms '()))
      (maphash (lambda (lengths count)
                 (push (mul count
                            (muln (mapcar (lambda (k) (list (list var 'array) k)) lengths) t))
                       terms))
               counts)
      (simplify (div (addn terms t) (length elements))))))

(defun $pgrp_regular (g)
  "Cayley's theorem: g acting on its own elements by left multiplication.
   Point i stands for the i-th element of pgrp_elements(g)."
  (let* ((h (perm-group-unwrap g '$pgrp_regular))
         (elements (perm-group-element-lists h '$pgrp_regular))
         (table (make-hash-table :test #'equal)))
    (loop :for e :in elements :for i :from 1 :do (setf (gethash e table) i))
    (perm-group-wrap
     (perm-group-make
      (mapcar (lambda (s)
                (mapcar (lambda (e) (gethash (perm-list-compose s e) table)) elements))
              (perm-group-generator-lists h))
      '$pgrp_regular))))

(defun $pgrp_colouring_orbits (g k)
  "One colouring from each orbit of g on the colourings of its points with
   colours 1, ..., k, as lists: entry i is the colour of point i. Each is
   the least in its orbit in lexicographic order, and there are
   pgrp_count_orbits(g, k) of them. g moves a colouring by carrying the
   colour at point i to point g(i)."
  (let* ((h (perm-group-unwrap g '$pgrp_colouring_orbits))
         (n (perm-group-handle-degree h))
         (gens (perm-group-generator-lists h)))
    (unless (and (integerp k) (>= k 1))
      (merror "pgrp_colouring_orbits: the number of colours must be a positive integer, got: ~M" k))
    (when (> (expt k n) $pgrp_max_elements)
      (merror "pgrp_colouring_orbits: ~M colourings is more than pgrp_max_elements = ~M"
              (expt k n) $pgrp_max_elements))
    (labels ((decode (m)
               ;; Colouring number m (0-based), most significant point first
               (let ((digits '()))
                 (dotimes (i n) (multiple-value-bind (q r) (floor m k) (push (1+ r) digits) (setf m q)))
                 digits))
             (encode (c)
               (reduce (lambda (acc d) (+ (* acc k) (1- d))) c :initial-value 0))
             (recolour (s c)
               (let ((new (make-list n)))
                 (loop :for colour :in c :for i :from 0 :do (setf (nth (1- (nth i s)) new) colour))
                 new)))
      (let ((seen (make-hash-table))
            (reps '()))
        (dotimes (m (expt k n))
          (unless (gethash m seen)
            (let ((start (decode m)))
              (push start reps)
              (setf (gethash m seen) t)
              (let ((frontier (list start)))
                (loop :while frontier
                      :do (let ((new '()))
                            (dolist (c frontier)
                              (dolist (s gens)
                                (let* ((d (recolour s c)) (code (encode d)))
                                  (unless (gethash code seen)
                                    (setf (gethash code seen) t)
                                    (push d new)))))
                            (setf frontier new)))))))
        (maxima-perm-lists (nreverse reps))))))

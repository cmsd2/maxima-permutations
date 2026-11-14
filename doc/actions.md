## Actions and counting

Any finite action gives a permutation group: number the points 1, ..., n and record where each generator sends them. Burnside's lemma and the cycle index then count colourings up to symmetry.

### Function: pgrp_from_action (gens, points, act)

Returns the permutation group that `gens` induce on the list `points` through `act(g, x)`.

Point `i` stands for `points[i]`. `gens` can be matrices, permutations or anything `act` accepts, and `act(g, x)` must return an element of `points`. In the example, GL_2(F_2) acts on the three nonzero vectors of F_2^2 as S_3.

#### Examples

```maxima
(%i1) X : [[0, 1], [1, 0], [1, 1]]$
(%i2) act : lambda([m, v], map(lambda([t], mod(t, 2)), list_matrix_entries(m . transpose(matrix(v)))))$
(%i3) G : pgrp_from_action([matrix([1, 1], [0, 1]), matrix([0, 1], [1, 0])], X, act)$
(%i4) [pgrp_order(G), pgrp_isomorphic_p(G, pgrp_symmetric(3))];
(%o4) [6, true]
```

See also: `pgrp_action_perm`, `pgrp_orbit`

### Function: pgrp_action_perm (g, points, act)

Returns the permutation of `points` that one element `g` induces through `act`.

Point `i` goes to the position of `act(g, points[i])` in `points`.

#### Examples

```maxima
(%i1) X : [[0, 1], [1, 0], [1, 1]]$
(%i2) act : lambda([m, v], map(lambda([t], mod(t, 2)), list_matrix_entries(m . transpose(matrix(v)))))$
(%i3) pgrp_action_perm(matrix([1, 1], [0, 1]), X, act);
(%o3) (1 3)
```

See also: `pgrp_from_action`

### Function: pgrp_orbit (G, x)

Returns the orbit of the point `x` under `G`, sorted.

#### Examples

```maxima
(%i1) pgrp_orbit(pgrp(pgrp_from_cycles([[1, 2]]), pgrp_from_cycles([[3, 4, 5]])), 4);
(%o1) [3, 4, 5]
```

See also: `pgrp_orbits`, `pgrp_stabiliser`

### Function: pgrp_stabiliser (G, x)

Returns the subgroup of `G` that fixes the point `x`.

By orbit–stabiliser, the orbit of `x` times the order of its stabiliser is the order of `G`.

#### Examples

```maxima
(%i1) S4 : pgrp_symmetric(4)$
(%i2) St : pgrp_stabiliser(S4, 4)$
(%i3) [pgrp_order(St), length(pgrp_orbit(S4, 4)), pgrp_isomorphic_p(St, pgrp_symmetric(3))];
(%o3) [6, 4, true]
```

See also: `pgrp_orbit`, `pgrp_stabiliser_chain`

### Function: pgrp_count_orbits (G, k)

Counts the colourings of the points of `G` with `k` colours, counting two as the same when an element of `G` turns one into the other.

This is Burnside's lemma: the average over `G` of k^c(g), where c(g) is the number of cycles of g, fixed points included. `k` may be a symbol, which gives a polynomial. The example colours the faces of a cube, labelled 1 up, 2 down, 3 front, 4 right, 5 back, 6 left.

#### Examples

```maxima
(%i1) cube : pgrp(pgrp_from_cycles([[3, 4, 5, 6]]), pgrp_from_cycles([[1, 4, 2, 6]]))$
(%i2) display2d : false$
(%i3) [pgrp_count_orbits(cube, 3), expand(pgrp_count_orbits(cube, k))];
(%o3) [57,k^6/24+k^4/8+k^3/2+k^2/3]
```

See also: `pgrp_cycle_index`, `pgrp_colouring_orbits`

### Function: pgrp_cycle_index (G)

Returns the cycle index of `G` as a polynomial in `x[1]`, `x[2]`, ...

Calling forms:

- `pgrp_cycle_index(G)`: in `x[1]`, `x[2]`, ...
- `pgrp_cycle_index(G, y)`: in `y[1]`, `y[2]`, ...

It averages x[1]^m_1 x[2]^m_2 ... over `G`, where m_j is the number of j-cycles. Substituting x[j] = r^j + b^j counts colourings by how often each colour is used (Pólya's theorem).

#### Examples

```maxima
(%i1) display2d : false$
(%i2) Z : pgrp_cycle_index(pgrp_cyclic(4));
(%o2) (2*x[4]+x[2]^2+x[1]^4)/4
(%i3) expand(subst(makelist(x[j] = r^j + b^j, j, 1, 4), Z));
(%o3) r^4+b*r^3+2*b^2*r^2+b^3*r+b^4
```

See also: `pgrp_count_orbits`

### Function: pgrp_colouring_orbits (G, k)

Returns one colouring from each orbit of `G` on the colourings of its points with colours 1, ..., `k`.

A colouring is a list whose entry `i` is the colour of point `i`; it is not a permutation. Each colouring returned is the least in its orbit, and there are `pgrp_count_orbits(G, k)` of them. `G` moves a colouring by carrying the colour at point i to point g(i).

#### Examples

```maxima
(%i1) pgrp_colouring_orbits(pgrp_dihedral(4), 2);
(%o1) [[1, 1, 1, 1], [1, 1, 1, 2], [1, 1, 2, 2], [1, 2, 1, 2], [1, 2, 2, 2], [2, 2, 2, 2]]
```

See also: `pgrp_count_orbits`

### Function: pgrp_regular (G)

Returns `G` acting on its own elements by left multiplication, as in Cayley's theorem.

Point `i` stands for the `i`-th element of `pgrp_elements(G)`.

#### Examples

```maxima
(%i1) R : pgrp_regular(pgrp_symmetric(3))$
(%i2) [pgrp_degree(R), pgrp_order(R), pgrp_isomorphic_p(R, pgrp_symmetric(3))];
(%o2) [6, 6, true]
```

See also: `pgrp_elements`, `pgrp_isomorphic_p`

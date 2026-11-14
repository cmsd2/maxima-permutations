## Single permutations

Composition reads right to left, as in Dummit and Foote §1.3: `pgrp_compose(s, t)` is s∘t, which applies `t` first. This is the opposite of the `combinatorics` package's `permult`: `permult(p, q)` equals `pgrp_compose(q, p)`.

### Function: pgrp_compose (s, t, ...)

Composes permutations right to left: `pgrp_compose(s, t)` applies `t` first, then `s`.

This is s∘t in Dummit and Foote's notation. With more arguments, `pgrp_compose(a, b, c)` is a∘b∘c, so `c` applies first. Permutations of different degrees are padded with fixed points. The examples are D&F's products (1 2 3)∘(1 2)(3 4) = (1 3 4) and (1 2)∘(1 3) = (1 3 2).

#### Examples

```maxima
(%i1) pgrp_compose(pgrp_from_cycles([[1, 2, 3]]), pgrp_from_cycles([[1, 2], [3, 4]]));
(%o1) (1 3 4)
(%i2) pgrp_compose(pgrp_from_cycles([[1, 2]]), pgrp_from_cycles([[1, 3]]));
(%o2) (1 3 2)
```

See also: `pgrp_inverse`, `pgrp_power`

### Function: pgrp_inverse (p)

Returns the inverse of the permutation `p`.

#### Examples

```maxima
(%i1) pgrp_inverse(pgrp_from_cycles([[1, 2, 3, 4]]));
(%o1) (1 4 3 2)
```

See also: `pgrp_compose`, `pgrp_power`

### Function: pgrp_power (p, k)

Returns `p` composed with itself `k` times.

`k` may be zero or negative.

#### Examples

```maxima
(%i1) r : pgrp_from_cycles([[1, 2, 3, 4]])$
(%i2) [pgrp_power(r, 2), pgrp_power(r, 4), pgrp_power(r, -1)];
(%o2) [(1 3)(2 4), (), (1 4 3 2)]
```

See also: `pgrp_compose`, `pgrp_element_order`

### Function: pgrp_identity (n)

Returns the identity permutation of degree `n`.

#### Examples

```maxima
(%i1) [pgrp_identity(4), pgrp_degree(pgrp_identity(4))];
(%o1) [(), 4]
```

See also: `pgrp_perm`

### Function: pgrp_cycles (p)

Returns the disjoint cycles of `p` as lists, leaving out fixed points.

Each cycle starts at its least point, and the cycles come in order of their least points. The identity gives `[]`. The example is D&F's permutation of 1, ..., 13 from §1.3.

#### Examples

```maxima
(%i1) pgrp_cycles(pgrp_perm([12, 13, 3, 1, 11, 9, 5, 10, 6, 4, 7, 8, 2]));
(%o1) [[1, 12, 8, 10, 4], [2, 13], [5, 11, 7], [6, 9]]
```

See also: `pgrp_from_cycles`, `pgrp_cycle_type`

### Function: pgrp_from_cycles (cycles)

Builds a permutation from a list of cycles, read as a product right to left.

Calling forms:

- `pgrp_from_cycles(cycles)`: the degree is the largest point in the cycles
- `pgrp_from_cycles(cycles, n)`: degree `n`

The cycles need not be disjoint: `pgrp_from_cycles([[1, 2], [1, 3]])` is (1 2)∘(1 3).

#### Examples

```maxima
(%i1) pgrp_from_cycles([[1, 2], [3, 4, 5]]);
(%o1) (1 2)(3 4 5)
(%i2) pgrp_from_cycles([[1, 2], [1, 3]]);
(%o2) (1 3 2)
(%i3) pgrp_degree(pgrp_from_cycles([[1, 2]], 5));
(%o3) 5
```

See also: `pgrp_cycles`, `pgrp_perm`

### Function: pgrp_element_order (p)

Returns the order of `p`, the least `k` at least 1 with `p^k` the identity.

It is the least common multiple of the cycle lengths.

#### Examples

```maxima
(%i1) pgrp_element_order(pgrp_from_cycles([[1, 2], [3, 4, 5], [6, 7, 8, 9]]));
(%o1) 12
```

See also: `pgrp_cycle_type`, `pgrp_order_profile`

### Function: pgrp_sign (p)

Returns 1 if `p` is even and -1 if it is odd.

An m-cycle is a product of m - 1 transpositions, so it is even exactly when m is odd.

#### Examples

```maxima
(%i1) map(lambda([c], pgrp_sign(pgrp_from_cycles([c]))), [[1, 2], [1, 2, 3], [1, 2, 3, 4]]);
(%o1) [- 1, 1, - 1]
```

See also: `pgrp_sign_hom`, `pgrp_alternating`

### Function: pgrp_cycle_type (p)

Returns the lengths of the cycles of `p`, fixed points included, largest first.

The lengths add up to the degree of `p`.

#### Examples

```maxima
(%i1) pgrp_cycle_type(pgrp_from_cycles([[1, 2]], 5));
(%o1) [2, 1, 1, 1]
```

See also: `pgrp_cycles`, `pgrp_element_order`

### Function: pgrp_conjugate (x, g)

Returns the conjugate g x g^-1.

Conjugating relabels the points: if `x` has the cycle (a b c), then g x g^-1 has the cycle (g(a) g(b) g(c)). In the example g = (1 3)(2 4 5) relabels (1 2 3) as (3 4 1), which is (1 3 4).

#### Examples

```maxima
(%i1) pgrp_conjugate(pgrp_from_cycles([[1, 2, 3]], 5), pgrp_from_cycles([[1, 3], [2, 4, 5]]));
(%o1) (1 3 4)
```

See also: `pgrp_conjugacy_class`, `pgrp_commutator`

### Function: pgrp_commutator (x, y)

Returns the commutator [x, y] = x^-1 y^-1 x y.

It is the identity exactly when `x` and `y` commute.

#### Examples

```maxima
(%i1) [pgrp_commutator(pgrp_from_cycles([[1, 2]], 3), pgrp_from_cycles([[2, 3]])),
       pgrp_commutator(pgrp_from_cycles([[1, 2]], 4), pgrp_from_cycles([[3, 4]]))];
(%o1) [(1 3 2), ()]
```

See also: `pgrp_derived_subgroup`, `pgrp_conjugate`

### Function: pgrp_fixed_points (p)

Returns the points that `p` leaves where they are, in increasing order.

#### Examples

```maxima
(%i1) pgrp_fixed_points(pgrp_from_cycles([[2, 4]], 5));
(%o1) [1, 3, 5]
```

See also: `pgrp_support`, `pgrp_count_orbits`

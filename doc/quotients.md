## Quotients and conjugacy

A quotient G/N is built as a permutation group: G acting on the left cosets of N.

### Function: pgrp_quotient (G, N)

Returns the quotient G/N of `G` by a normal subgroup `N`, as `G` acting on the left cosets of `N`.

Point `i` stands for the `i`-th coset of `pgrp_left_cosets(G, N)`.

#### Examples

```maxima
(%i1) S4 : pgrp_symmetric(4)$
(%i2) V4 : pgrp(pgrp_from_cycles([[1, 2], [3, 4]]), pgrp_from_cycles([[1, 3], [2, 4]]))$
(%i3) Q : pgrp_quotient(S4, V4)$
(%i4) [pgrp_order(Q), pgrp_isomorphic_p(Q, pgrp_symmetric(3))];
(%o4) [6, true]
```

See also: `pgrp_quotient_hom`, `pgrp_left_cosets`

### Function: pgrp_quotient_hom (G, N)

Returns the homomorphism from `G` onto `pgrp_quotient(G, N)` that sends g to its coset gN.

Its kernel is `N`.

#### Examples

```maxima
(%i1) S4 : pgrp_symmetric(4)$
(%i2) V4 : pgrp(pgrp_from_cycles([[1, 2], [3, 4]]), pgrp_from_cycles([[1, 3], [2, 4]]))$
(%i3) q : pgrp_quotient_hom(S4, V4)$
(%i4) [pgrp_order(pgrp_kernel(q)), pgrp_order(pgrp_image(q))];
(%o4) [4, 6]
```

See also: `pgrp_quotient`, `pgrp_kernel`

### Function: pgrp_conjugacy_classes (G)

Returns the conjugacy classes of `G`, with the identity's first.

Each class is sorted, and the classes come in order of their least elements.

#### Examples

```maxima
(%i1) pgrp_conjugacy_classes(pgrp_symmetric(3));
(%o1) [[()], [(2 3), (1 2), (1 3)], [(1 2 3), (1 3 2)]]
```

See also: `pgrp_conjugacy_class`, `pgrp_conjugate`

### Function: pgrp_conjugacy_class (G, x)

Returns the conjugacy class of `x` in `G`, every g x g^-1 for g in `G`.

In A_4 the eight 3-cycles split into two classes of four.

#### Examples

```maxima
(%i1) pgrp_conjugacy_class(pgrp_alternating(4), pgrp_from_cycles([[1, 2, 3]], 4));
(%o1) [(2 4 3), (1 2 3), (1 3 4), (1 4 2)]
```

See also: `pgrp_conjugacy_classes`, `pgrp_conjugate`

### Function: pgrp_normal_subgroups (G)

Returns every normal subgroup of `G`, smallest first.

#### Examples

```maxima
(%i1) map(pgrp_order, pgrp_normal_subgroups(pgrp_symmetric(4)));
(%o1) [1, 4, 12, 24]
```

See also: `pgrp_subgroups`, `pgrp_normal_p`, `pgrp_simple_p`

### Function: pgrp_normal_closure (G, S)

Returns the smallest normal subgroup of `G` that contains `S`, a list of permutations or a group.

#### Examples

```maxima
(%i1) pgrp_elements(pgrp_normal_closure(pgrp_symmetric(4), [pgrp_from_cycles([[1, 2], [3, 4]])]));
(%o1) [(), (1 2)(3 4), (1 3)(2 4), (1 4)(2 3)]
```

See also: `pgrp_normal_subgroups`

### Function: pgrp_simple_p (G)

Returns `true` if `G` is simple: not trivial, with no normal subgroups other than the trivial group and `G`.

#### Examples

```maxima
(%i1) [pgrp_simple_p(pgrp_alternating(5)), pgrp_simple_p(pgrp_alternating(4)), pgrp_simple_p(pgrp_cyclic(7))];
(%o1) [true, false, true]
```

See also: `pgrp_normal_subgroups`, `pgrp_composition_series`

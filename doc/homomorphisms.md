## Homomorphisms and isomorphisms

A homomorphism between permutation groups is fixed by the images of the generators. `pgrp_hom` checks that the images define one.

### Function: pgrp_hom (G, H, images)

Returns the homomorphism from `G` to `H` that sends the generators of `G` to `images`.

`images` lists one element of `H` for each element of `pgrp_generators(G)`, in that order. Fails if no homomorphism does that. A homomorphism displays as `pgrp_hom(degree m to degree n)`. The example squares in Z_4.

#### Examples

```maxima
(%i1) Z4 : pgrp_cyclic(4)$
(%i2) sq : pgrp_hom(Z4, Z4, [pgrp_power(first(pgrp_generators(Z4)), 2)]);
(%o2) pgrp_hom(degree 4 to degree 4)
(%i3) pgrp_elements(pgrp_kernel(sq));
(%o3) [(), (1 3)(2 4)]
```

See also: `pgrp_hom_apply`, `pgrp_kernel`, `pgrp_image`

### Function: pgrp_hom_apply (phi, p)

Returns the image of the permutation `p` under the homomorphism `phi`.

#### Examples

```maxima
(%i1) sgn : pgrp_sign_hom(pgrp_symmetric(4))$
(%i2) [pgrp_hom_apply(sgn, pgrp_from_cycles([[1, 2]], 4)), pgrp_hom_apply(sgn, pgrp_from_cycles([[1, 2, 3]], 4))];
(%o2) [(1 2), ()]
```

See also: `pgrp_hom`

### Function: pgrp_hom_p (x)

Returns `true` if `x` is a homomorphism.

#### Examples

```maxima
(%i1) [pgrp_hom_p(pgrp_sign_hom(pgrp_symmetric(3))), pgrp_hom_p(pgrp_symmetric(3))];
(%o1) [true, false]
```

See also: `pgrp_hom`, `pgrp_p`

### Function: pgrp_kernel (phi)

Returns the kernel of `phi`, the subgroup of its source that it sends to the identity.

#### Examples

```maxima
(%i1) K : pgrp_kernel(pgrp_sign_hom(pgrp_symmetric(4)))$
(%i2) [pgrp_order(K), pgrp_isomorphic_p(K, pgrp_alternating(4))];
(%o2) [12, true]
```

See also: `pgrp_image`, `pgrp_preimage`

### Function: pgrp_image (phi)

Returns the image of `phi`, a subgroup of its target.

By the first isomorphism theorem, the orders of the kernel and the image multiply to the order of the source.

#### Examples

```maxima
(%i1) sgn : pgrp_sign_hom(pgrp_symmetric(4))$
(%i2) [pgrp_order(pgrp_image(sgn)), pgrp_order(pgrp_kernel(sgn)) * pgrp_order(pgrp_image(sgn))];
(%o2) [2, 24]
```

See also: `pgrp_kernel`

### Function: pgrp_preimage (phi, K)

Returns the elements of the source that `phi` sends into the subgroup `K` of its target.

#### Examples

```maxima
(%i1) sgn : pgrp_sign_hom(pgrp_symmetric(3))$
(%i2) pgrp_elements(pgrp_preimage(sgn, pgrp(pgrp_identity(2))));
(%o2) [(), (1 2 3), (1 3 2)]
```

See also: `pgrp_kernel`, `pgrp_image`

### Function: pgrp_isomorphism (G, H)

Returns an isomorphism from `G` to `H`, or `false` if there is none.

It compares invariants first, then searches for images of the generators. In the example the isomorphism from Z_6 to Z_2 x Z_3 sends the 6-cycle to a 2-cycle times a 3-cycle, and Z_4 is not isomorphic to the Klein four-group.

#### Examples

```maxima
(%i1) iso : pgrp_isomorphism(pgrp_cyclic(6), pgrp_direct_product(pgrp_cyclic(2), pgrp_cyclic(3)))$
(%i2) pgrp_hom_apply(iso, pgrp_from_cycles([[1, 2, 3, 4, 5, 6]]));
(%o2) (1 2)(3 4 5)
(%i3) pgrp_isomorphism(pgrp_cyclic(4), pgrp(pgrp_from_cycles([[1, 2], [3, 4]]), pgrp_from_cycles([[1, 3], [2, 4]])));
(%o3) false
```

See also: `pgrp_isomorphic_p`

### Function: pgrp_isomorphic_p (G, H)

Returns `true` if `G` and `H` are isomorphic.

#### Examples

```maxima
(%i1) [pgrp_isomorphic_p(pgrp_dihedral(3), pgrp_symmetric(3)), pgrp_isomorphic_p(pgrp_dihedral(4), pgrp_quaternion())];
(%o1) [true, false]
```

See also: `pgrp_isomorphism`, `pgrp_order_profile`

### Function: pgrp_order_profile (G)

Returns how many elements of `G` have each order, as `[order, count]` pairs.

Isomorphic groups have the same profile, so a difference shows two groups are not isomorphic. D_8 and Q_8 differ in their elements of order 2.

#### Examples

```maxima
(%i1) [pgrp_order_profile(pgrp_dihedral(4)), pgrp_order_profile(pgrp_quaternion())];
(%o1) [[[1, 1], [2, 5], [4, 2]], [[1, 1], [2, 1], [4, 6]]]
```

See also: `pgrp_isomorphic_p`, `pgrp_element_order`

### Function: pgrp_sign_hom (G)

Returns the sign homomorphism from `G` onto Z_2 = {(), (1 2)}.

Even elements go to the identity and odd ones to (1 2), so the kernel is the even part of `G`.

#### Examples

```maxima
(%i1) pgrp_elements(pgrp_kernel(pgrp_sign_hom(pgrp_dihedral(4))));
(%o1) [(), (1 2)(3 4), (1 3)(2 4), (1 4)(2 3)]
```

See also: `pgrp_sign`, `pgrp_kernel`

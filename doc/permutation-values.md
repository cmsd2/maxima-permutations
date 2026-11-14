## Permutation values

Functions return permutations as `pgrp_perm` values, shown in cycle notation. Every function also accepts a list of images, the form the `combinatorics` package uses: `[2,1,3]` sends 1 to 2, 2 to 1 and 3 to 3. A `pgrp_perm` keeps its degree, and equal permutations of the same degree are the same value, so `=`, `member`, `unique` and `setify` work on them.

### Function: pgrp_perm (l)

Turns a list of images into a permutation value.

Entry `i` of `l` is the image of `i`. The value keeps the degree `length(l)`. `string(p)` gives `pgrp_perm([...])`, which reads back as the same value, and `tex(p)` gives the cycles.

#### Examples

```maxima
(%i1) p : pgrp_perm([2, 3, 1, 4]);
(%o1) (1 2 3)
(%i2) pgrp_degree(p);
(%o2) 4
(%i3) is(p = pgrp_from_cycles([[1, 2, 3]], 4));
(%o3) true
(%i4) string(p);
(%o4) pgrp_perm([2,3,1,4])
```

See also: `pgrp_perm_list`, `pgrp_from_cycles`, `pgrp_perm_p`

### Function: pgrp_perm_p (x)

Returns `true` if `x` is a permutation value, and `false` for anything else, including a list of images.

#### Examples

```maxima
(%i1) [pgrp_perm_p(pgrp_perm([2, 1])), pgrp_perm_p([2, 1])];
(%o1) [true, false]
```

See also: `pgrp_perm`

### Function: pgrp_perm_list (p)

Returns the list of images of the permutation `p`.

Calling forms:

- `pgrp_perm_list(p)`: the images, one for each point up to the degree of `p`
- `pgrp_perm_list(p, n)`: padded with fixed points to length `n`; fails if `p` moves a point above `n`

#### Examples

```maxima
(%i1) p : pgrp_from_cycles([[1, 3]]);
(%o1) (1 3)
(%i2) pgrp_perm_list(p);
(%o2) [3, 2, 1]
(%i3) pgrp_perm_list(p, 5);
(%o3) [3, 2, 1, 4, 5]
```

See also: `pgrp_perm`, `pgrp_apply`

### Function: pgrp_apply (p, i)

Returns the image of the point `i` under the permutation `p`.

Points beyond the degree of `p` are fixed.

#### Examples

```maxima
(%i1) p : pgrp_from_cycles([[1, 2, 3]])$
(%i2) makelist(pgrp_apply(p, i), i, 1, 5);
(%o2) [2, 3, 1, 4, 5]
```

See also: `pgrp_perm_list`, `pgrp_support`

### Function: pgrp_support (p)

Returns the points that `p` moves, in increasing order.

#### Examples

```maxima
(%i1) pgrp_support(pgrp_from_cycles([[2, 5], [3, 4, 6]]));
(%o1) [2, 3, 4, 5, 6]
```

See also: `pgrp_fixed_points`, `pgrp_apply`

### Function: pgrp_eq (p, q)

Returns `true` if `p` and `q` are the same permutation, whatever their degrees.

`=` also compares degrees, so (1 2) of degree 2 and (1 2) of degree 3 are different under `=` and equal under `pgrp_eq`. A shorter permutation counts as fixing the extra points. Either argument may be a list of images.

#### Examples

```maxima
(%i1) a : pgrp_perm([2, 1])$
(%i2) b : pgrp_perm([2, 1, 3])$
(%i3) [is(a = b), pgrp_eq(a, b), pgrp_eq(a, [2, 1, 3, 4])];
(%o3) [false, true, true]
```

See also: `pgrp_perm`, `pgrp_sort`

### Function: pgrp_sort (l)

Sorts a list of permutations by their lists of images.

Shorter permutations are compared as if padded with fixed points. Each element keeps its own form, a `pgrp_perm` value or a list.

#### Examples

```maxima
(%i1) pgrp_sort([pgrp_perm([3, 1, 2]), pgrp_perm([2, 1, 3]), pgrp_identity(3)]);
(%o1) [(), (1 2), (1 3 2)]
```

See also: `pgrp_eq`, `pgrp_elements`

### Variable: pgrp_perm_output

Default value: `true`. When `true`, functions return permutations as `pgrp_perm` values; when `false`, they return lists of images.

Colourings and lists of invariant factors are lists either way, since they are not permutations.

#### Examples

```maxima
(%i1) pgrp_compose([2, 3, 1], [2, 1, 3]);
(%o1) (1 3)
(%i2) pgrp_perm_output : false$
(%i3) pgrp_compose([2, 3, 1], [2, 1, 3]);
(%o3) [3, 2, 1]
```

See also: `pgrp_perm`, `pgrp_perm_list`

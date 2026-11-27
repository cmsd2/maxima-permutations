# Changelog

Notable changes to permutations.  The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/) (in 0.x, a minor bump can break
compatibility).

## [Unreleased]

## [0.2.0] - 2026-11-27

### Added

- **Cayley graphs**: `pgrp_cayley_graph(G, [gens])` returns the graph as
  `[n, edges]`.  Vertex i is the i-th element of `pgrp_elements(G)`, and
  edge `[i, j, k]` joins g_i to g_i∘s_k.  A generator of order 2 gives each
  edge once.  The lists are plain, so ax-plots' `ax_graph` draws them
  directly.
- **Spectral layout**: `pgrp_spectral_layout(C, [dim])` places each vertex
  of a graph `[n, edges]` using its Laplacian's eigenvectors, in 3
  dimensions by default.  A Cayley graph comes out with the group's
  symmetry: A5 from an element of order 5 and one of order 2 gives the
  truncated icosahedron, S4 the truncated octahedron.  It refuses a `dim`
  that splits a repeated eigenvalue and lists the sizes that work.
  `pgrp_spectral_max_vertices` (default 1000) caps the graph size.

## [0.1.0] - 2026-11-22

The first version: permutation groups built on cl-permutation (SBCL only).
Groups by generators and the named families, order and membership by
Schreier–Sims, permutation arithmetic and cycles, Cayley tables, actions
and counting, homomorphisms and isomorphism, subgroups, cosets, quotients,
series and Sylow subgroups, and `pgrp_perm` values shown in cycle notation.

[Unreleased]: https://github.com/cmsd2/maxima-permutations/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/cmsd2/maxima-permutations/compare/7ac1da8...v0.2.0
[0.1.0]: https://github.com/cmsd2/maxima-permutations/commits/7ac1da8

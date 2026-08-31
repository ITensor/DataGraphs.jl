# Changelog

## [0.6.0](https://github.com/ITensor/DataGraphs.jl/compare/v0.5.3...main) - Unreleased

### Breaking changes

- Requires NamedGraphs v0.14. The graph types here are `AbstractNamedGraph`
  subtypes, so its breaking changes carry through to them, including the output
  types of `vertices` and `edges` and the return values of the mutating
  functions. See the
  [NamedGraphs changelog](https://itensor.github.io/NamedGraphs.jl/stable/changelog/)
  ([#126](https://github.com/ITensor/DataGraphs.jl/pull/126)).

### Non-breaking changes

- `quotient_graph` of a `PartitionedView` of a `DataGraph` works, where it
  previously threw and read the edge data from the wrong edge
  ([#126](https://github.com/ITensor/DataGraphs.jl/pull/126)).
- The method ambiguities in the package are resolved, and
  `Aqua.test_ambiguities` is enabled to keep them from coming back
  ([#126](https://github.com/ITensor/DataGraphs.jl/pull/126)).

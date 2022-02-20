# MyToolbox.jl

To import at the start of an interactive session. Re-exports useful, small libraries, and defines miscellaneous utility functions that don't fit in a proper package.


## Showcase

```julia-repl
julia> using MyToolbox

julia> @alias ODict = OrderedDict;  # Expands to:
       # @doc (@doc OrderedDict) const ODict = OrderedDict;

julia> neuron_IDs = idvec(exc = 5200, inh = 1300, unconn = 100)
ComponentVector(…)

julia> showsome(labels(neuron_IDs))  # More compact than `show`.
6600-element Vector{String}:
    1: "exc[1]"
    2: "exc[2]"
    ⋮
   21: "exc[21]"
    ⋮
 6168: "inh[968]"
    ⋮
 6599: "unconn[99]"
 6600: "unconn[100]"

 julia> ziplongest([1,2,3], [1,2]);
        # Equivalent to `zip([1,2,3], [1,2,nothing])`
 ```
 <!-- todo: break this up in short  `julia` blocks, with markdown in between. -->


## Installation

As this package is not registered (yet), use
```julia
Pkg.add(url="https://github.com/tfiers/MyToolbox.jl")
```

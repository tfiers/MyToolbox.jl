# MyToolbox.jl

To import at the start of an interactive session. Re-exports useful libraries, and defines miscellaneous utility functions that don't fit in a proper package.


## Showcase

```julia-repl
julia> using MyToolbox, ComponentArrays

julia> @alias CArray = ComponentArray;  # Expands to:
       # @doc (@doc ComponentArray) const CArray = Componentarray;

julia> neuron_ids = CArray(E = 1:5200, I = 1:1300, unconn = 1:100);

julia> showsome(labels(neuron_ids))  # More compact than `show`.
6600-element Vector{String}:
    1: "E[1]"
    2: "E[2]"
    ⋮
   21: "E[21]"
    ⋮
 6168: "I[968]"
    ⋮
 6599: "unconn[99]"
 6600: "unconn[100]"
 ```


## Installation

As this package is not registered, use
```julia
Pkg.add(url="https://github.com/fonsp/Suppressor.jl.git")
```

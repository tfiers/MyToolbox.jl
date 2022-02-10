module MyToolbox

using Reexport

@reexport using Base.Iterators         # `partition`, `cycle`, `flatten` ("chain"), …
@reexport using StatsBase              # `sample`, `describe`, …; plus reexports `Statistics` from stdlib.
@reexport using DataFrames, PrettyTables
@reexport using PartialFunctions,      # Currying (`func $ a`, like `partial(func, a)` in Python).
                PyFormattedStrings,    # f-strings as in Python (but with C format spec).
                LaTeXStrings,          # `L"These strings can contain $ and \ without escaping"`.
                FilePaths,             # `Path` type and `/` joins, as in Python.
                Printf                 # `@printf`, `@sprintf`
@reexport using IJulia
@reexport using BenchmarkTools, Profile
@reexport using LoggingExtras
@reexport using Sciplotlib
@reexport using Unitful                # [used in `move_units_to_header(df)`]

include("figures.jl")
export savefig

include("dataframes.jl")
export printsimple

include("macros.jl")
export @alias, @exportn

include("misctools.jl")
export ziplongest

include("show.jl")
export showsome

end # module

module MyToolbox

using Reexport

@reexport using DataFrames, PrettyTables
@reexport using PartialFunctions,      # Currying (`func $ a`, like `partial(func, a)` in Python).
                PyFormattedStrings,    # f-strings as in Python (but with C format spec).
                LaTeXStrings,          # `L"These strings can contain $ and \ without escaping"`.
                FilePaths,             # `Path` type and `/` joins, as in Python.
                Printf
@reexport using IJulia
@reexport using BenchmarkTools, Profile
@reexport using LoggingExtras
@reexport using Sciplotlib
@reexport using Unitful                # (Used in `move_units_to_header(df)`)

include("figures.jl")
export savefig

include("dataframes.jl")
export printsimple

include("show.jl")

end # module

module MyToolbox

using Reexport, Requires

@reexport using Base.Iterators         # `partition`, `cycle`, `flatten` ("chain"), …
@reexport using DataStructures         # `DefaultDict`, `OrderedDict`, `counter`, queues, …
@reexport using Random
@reexport using StatsBase              # `sample`, `describe`, …. Plus: reexports `Statistics` from stdlib.
@reexport using PartialFunctions,      # Currying (`func $ a`, like `partial(func, a)` in Python).
                PyFormattedStrings,    # f-strings as in Python (but with C format spec).
                LaTeXStrings,          # `L"These strings can contain $ and \ without escaping"`.
                FilePaths,             # `Path` type and `/` joins, as in Python.
                Printf                 # `@printf`, `@sprintf`
@reexport using IJulia
@reexport using ProgressMeter
@reexport using BenchmarkTools
@reexport using Profile, ProfileView   # `@profview`
@reexport using LoggingExtras
@reexport using ComponentArrays
@reexport using Parameters
@reexport using Base: @kwdef
@reexport using Pkg

include("macros.jl")
export @alias, @exportn

include("show.jl")
export showsome

include("cvec.jl")
export CVec, idvec

include("iter.jl")
export ziplongest, chain

include("misctools.jl")
export resetrng!, linspace

function __init__()
    @require PyPlot = "d330b81b-6aea-500a-939a-2ce795aea3ee" begin
        include("figures.jl")
        export savefig
    end
    @require DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0" begin
        include("dataframes.jl")
        export printsimple
    end
end

end # module

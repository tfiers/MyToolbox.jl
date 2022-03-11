module MyToolbox

using Reexport
using Requires
# `@reexport using Requires` and then `using MyToolbox; @require …` in a module does not
# seem to work.

@reexport using Requires
@reexport using Base.Iterators         # `partition`, `cycle`, `flatten` ("chain"), …
@reexport using DataStructures         # `DefaultDict`, `OrderedDict`, `counter`, queues, …
@reexport using Random
@reexport using StatsBase              # `sample`, `describe`, …. Plus: reexports `Statistics` from stdlib
@reexport using PartialFunctions,      # Currying (`func $ a`, like `partial(func, a)` in Python)
                PyFormattedStrings,    # f-strings as in Python (but with C format spec)
                LaTeXStrings,          # `L"These strings can contain $ and \ without escaping"`
                FilePaths,             # `Path` type and `/` joins, as in Python
                Printf                 # `@printf`, `@sprintf`
@reexport using IJulia
@reexport using ProgressMeter          # `@showprogress`
@reexport using BenchmarkTools: @benchmark, @btime  # Don't import all, bc that includes `params`,
                                                    # which conflicts when `Distributions` is loaded.
@reexport using Profile, ProfileView   # `@profview`
@reexport using Logging, LoggingExtras
@reexport using ComponentArrays
@reexport using Setfield: @set, @set!  # `immut = @set immut.some.field = new`.
                                       # Method (not macro) `set` clashes with Sciplotlib's.
@reexport using Parameters             # `@unpack`, `@pack!`, `@with_kw` (> `Base.@kwdef`)
@reexport using Pkg

include("macros.jl")
export @alias

include("show.jl")
export dumps, showsome

include("cvec.jl")
export CVec, idvec

include("iter.jl")
export ziplongest, chain

include("misctools.jl")
export resetrng!, linspace

function __init__()
    # See includes below for additional imports and @reexports of MyToolbox, besides those
    # in the current file.
    @require PyPlot = "d330b81b-6aea-500a-939a-2ce795aea3ee" begin
        include("figures.jl")
        export savefig
    end
    @require DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0" begin
        include("dataframes.jl")
        export printsimple
    end
    if isdefined(Main, :IJulia) && Main.IJulia.inited
        prettify_logging_in_IJulia()
    end
    # [a todo: eval this in Main: `using FilePathsBase: /`]
end

end # module

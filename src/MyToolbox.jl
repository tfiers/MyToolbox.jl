module MyToolbox


using Reexport
export @reexport

@reexport using Pkg,
    Random,
    Printf,
    Logging,
    Profile,
    Base.Iterators,        # `partition`, `cycle`, `flatten` (= chain), …
    Markdown,              # `.parse`, `.html`
    # ↑ stdlib
    # ↓ ecosystem
    DataStructures,        # `DefaultDict`, `OrderedDict`, `counter`, queues, …
    StatsBase,             # `sample`, `describe`, …. Plus: reexports `Statistics` from stdlib
    PartialFunctions,      # Currying: `func $ a`, which is like `partial(func, a)` in Python
    PyFormattedStrings,    # f-strings as in Python (but with C format spec)
    LaTeXStrings,          # `L"These strings can contain $ and \ without escaping"`
    Requires,              # `@require SomePkg …` in `__init__`.
    IJulia,                # Jupyter notebook kernel
    ProgressMeter,         # `@showprogress`
    LoggingExtras,         # `TeeLogger`, `ActiveFilteredLogger`, …
    ComponentArrays,
    Parameters,            # `@unpack`, `@pack!`, `@with_kw` (> `Base.@kwdef`)
    Match,                 # `@match` pattern matching / switch case
    JLD2,                  # Saving Julia types to HDF5
    Chain                  # `@chain df begin`
    # ↓ pruned
    # Suppressor,          # `@suppress` print output in a function/block. Not threadsafe.

@reexport using BenchmarkTools: @benchmark, @btime
    # By default exports `params`, which conflicts with `Distributions` when that is loaded.

@reexport using Setfield: @set, @set!   # `@set! immut.some.field = new`.
    # `set` (the by default exported method, not the @macro) clashes with Sciplotlib's.



include("macros.jl")
export @alias, @withfb

include("show.jl")
export dumps, showsome, set_print_precision, set_float_print_fmt

include("displaytable.jl")
export DisplayTable

include("cvec.jl")
export CVec, idvec, scalar

include("iter.jl")
export ziplongest, chain

include("misctools.jl")
export resetrng!, linspace


function __init__()

    # See included files below for additional imports and @reexports of MyToolbox, besides
    # those in this file.
    @require PyPlot = "d330b81b-6aea-500a-939a-2ce795aea3ee" begin
        include("figures.jl")
        export savefig
        autodisplay_figs_in_sysimg()
    end

    @require DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0" begin
        include("dataframes.jl")
        export printsimple, disp
    end

    if isdefined(Main, :IJulia) && Main.IJulia.inited
        prettify_logging_in_IJulia()
        output_html_too_for_md()
    end

    # Cannot `set_print_precision` here if MyToolbox is not the top level module. (Then
    # error: `InitError: Evaluation into the closed module breaks incremental compilation
    # [..]`).
end


end # module

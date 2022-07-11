
"""
    resetrng!([seed])

Reset the random number generator to a new seed.
Either use the given seed, or if none is given, choose one at random and print it.

Call at the start of a script or notebook cell to make it reproducible.

Example use case: re-run some plotting code that contains a random element, a few times,
until the plot looks good (🍒); then lock that in.
To do that, run the first times with `resetrng!()`, without argument. The new seed will be
printed every time. When you have a plot that looks good, copy the last printed seed
and edit the call to use this seed: `resetrng!(2882)`.

New seeds are sampled from the keyword argument `possible_seeds`, which is `1:999` by
default, but could also e.g. be `Int`.
"""
function resetrng!(seed = nothing; possible_seeds = 1:999)
    if isnothing(seed)
        seed = rand(possible_seeds)
        @show seed
    end
    Random.seed!(seed)
end


"""
    linspace(start, stop, num; endpoint = false)

Example:

    linspace(0, 10, num=5)  →  [0, 2, 4, 6, 8]

Create a `range` of `num` numbers evenly spaced between `start` and `stop`. The endpoint
`stop` is by default not included. `num` can be specified positionally or as keyword.

Why this function? Because `endpoint = false` functionality is missing in Base.
"""
function linspace(start, stop, num; endpoint = false)
    if endpoint
        return range(start, stop, num)
    else
        return range(start, stop, num + 1)[1:end-1]
    end
end
linspace(start, stop; num, endpoint = false) = linspace(start, stop, num; endpoint)

# - `linspace` functionality will not come to Base [1] (i.e. to `range` aka
#   `start:step:stop`; nor to `LinRange()`, which does not correct for floating point
#   error).
#   I disagree: the vanilla solution is kinda verbose and unclear. And `linspace` is a
#   common need: e.g. to get the correct timepoints for an evenly sampled signal:
#   `timepoints = linspace(0, N/fs, N)`,
#   where `N` is the number of samples in the signal, and `fs` is the sampling rate.
#
# - An alternative to `linspace` is this nice conceptualization [2]:
#   "binspace(left|center|right)"
#   `linspace(endpoint=False)` is like making bins and returning just the left edges.
#
# [1]: https://github.com/JuliaLang/julia/issues/27097
# [2]: https://discourse.julialang.org/t/proposal-of-numpy-like-endpoint-option-for-linspace/6916/13


function set_print_precision(digits = 3)
    fmt = Printf.Format("%.$(digits)G")
    eval( :( Base.show(io::IO, x::Float64) = Printf.format(io, $fmt, x) ))
end

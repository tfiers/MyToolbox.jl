
"""
    resetrng!([seed])

Reset the random number generator to a new seed. If none is given, choose one at random, and
print it. This makes notebook cells that start with `resetrng!` reproducible.

Example use case: retry a plot containing some random element a few times, as `resetrng!();
plot(…)`, until the result looks nice (🍒). Then note the last printed seed, and pass it in
the initial call: `resetrng!(283); plot(…)`.

New seeds are sampled from the keyword argument `possible_seeds`, which is `1:999` by
default, but can be anything accepted by `rand()` (like `Int`).
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

Create a `range` of `num` numbers evenly spaced between `start` and `stop`. The endpoint
`stop` is by default not included. `num` can be specified positionally or as keyword.

(`endpoint = false` functionality is missing in Base. Hence this small utility function).
"""
function linspace(start, stop, num; endpoint = false)
    if endpoint
        return range(start, stop, num)
    else
        return range(start, stop, num + 1)[1:end-1]
    end
end
linspace(start, stop; num, endpoint = false) = linspace(start, stop, num; endpoint)
# - This functionality will not come to Base (i.e. to `range` aka `start:step:stop`; and
#   `LinRange()`, which does not correct for floating point error): [1].
#    I disagree: vanilla solution is kinda verbose and unclear.
# - An alternative to `linspace` is this nice conceptualization [2]:
#   "binspace(left|center|right)": `linspace(endpoint=False)` is like making bins and
#   returning just the left edges.
# [1]: https://github.com/JuliaLang/julia/issues/27097
# [2]: https://discourse.julialang.org/t/proposal-of-numpy-like-endpoint-option-for-linspace/6916/13

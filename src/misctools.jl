
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

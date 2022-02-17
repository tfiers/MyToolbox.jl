
# `zip_longest` is not in Base.Itertools, and not merged yet in IterTools.jl.
# Hence, this.
"""
    ziplongest(iters...; padval = nothing)

`zip` the given iterators after appending `padval` to the shorter ones. The returned
iterator has the same length as the longest iterator in `iters`.

For example, `ziplongest([1,2,3], [1,2])` yields an iterator with the values
`[(1,1), (2,2), (3,nothing)]`.

If any iterators are infinite (*e.g.*: `countfrom`), the returned iterator runs to the
length of the longest finite iterator. If they are all infinite, simply `zip` them.
"""
function ziplongest(iters...; padval = nothing)
    iter_is_finite = applicable.(length, iters)
    if any(iter_is_finite)
        maxfinitelength = maximum(length, iters[collect(iter_is_finite)])
            # Logical index must be an Array, not a Tuple. Hence, `collect`.
        pad(iter) = chain(iter, repeated(padval))
        padded_zip = zip(pad.(iters)...)
        return take(padded_zip, maxfinitelength)
    else
        return zip(iters...)
    end
end

# To be consistent with e.g. `zip`'s interface. Also, `chain` is a more common name for this
# operation.
chain(iters...) = Iterators.flatten(iters)

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

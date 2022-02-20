
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

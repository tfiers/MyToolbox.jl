
# `zip_longest` is not in Base.Itertools, and not merged yet in IterTools.jl.
# Hence, this.
function ziplongest(iters...; sentinel = nothing)
    maxlen = maximum(length, iters)  # only iterators with a `length` are supported
    fill_out(iter) = Iterators.flatten([iter, repeated(sentinel, maxlen - length(iter))])
    return zip(fill_out.(iters)...)
end


# `zip_longest` is not in Base.Itertools, and not merged yet in IterTools.jl.
# Hence, this.
function ziplongest(iters...; sentinel = nothing)
    all(iter -> Base.IteratorSize(typeof(iter)) == Base.HasLength(), iters) ||
        error("only iterators with a `length` are supported")
    N = maximum(length, iters)
    fill_out(iter) = Iterators.flatten([iter, repeated(sentinel, N - length(iter))])
    return zip(fill_out.(iters)...)
end

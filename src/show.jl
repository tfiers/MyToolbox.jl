#=
Human friendly text representations of relevant types.

IJulia and the REPL call `show(::IO, ::MIME"text/plain", x)` on objects.
(which defaults to `show(::IO, x)` -- which is meant for serialising, not humans.
Hence we overload).
=#

# Non-full precision printing of all floats.
Base.show(io::IO, ::MIME"text/plain", x::Float64) =
    show(IOContext(io, :compact => true), x)

"""
    showsome(x; kw...)
    showsome(io::IO, x; kw...)

Print an overview of the vector `x`, by showing example entries. The first and last
entries are shown, and a few randomly sampled entries in between.

Keyword arguments `nfirst`, `nlast`, and `nsample` determine how many samples to print at
the beginning, end, and in between. Each defaults to `2`. `io` is `stdout` if not specified.
"""
showsome(x        ; nfirst = 2, nlast = 2, nsample = 2) = showsome(stdout, x; nfirst, nlast, nsample)
showsome(io::IO, x; nfirst = 2, nlast = 2, nsample = 2) = begin
    if length(x) ≤ nfirst + nlast + nsample
        nfirst = length(x)
        nlast, nsample = 0, 0
    end
    println(io, summary(x), ":")  # eg "640-element Vector{String}:"
    all_i = 1:length(x)  # Always `Int`s
    all_ix = eachindex(x)  # Generally same, but can also be `CartesianIndex`, `Symbol`, …
    shown_i = @views vcat(
        all_i[1:nfirst],
        all_i[nfirst+1:end-nlast] |> (is -> sample(is, nsample)) |> sort,
        all_i[end-nlast+1:end],
    )
    shown_ix = all_ix[shown_i]
    padlen = 1 + maximum(length, string.(shown_ix))
        # The initial extra `1` is the one-space indent of vanilla Vector printing.
    printrow(ix) = println(io, lpad(ix, padlen), ": ", repr(x[ix]))
    printdots() = println(io, lpad("⋮", padlen))
    first(shown_i) == first(all_i) || printdots()
    for (i, inext) in ziplongest(shown_i, shown_i[2:end])
        printrow(all_ix[i])
        isnothing(inext) || inext == i + 1 || printdots()
    end
    last(shown_i) == last(all_i) || printdots()
    return nothing
end

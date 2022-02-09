#=
Human friendly text representations of relevant types.

IJulia and the REPL call `show(::IO, ::MIME"text/plain", x)` on objects.
(which defaults to `show(::IO, x)` -- which is meant for serialising, not humans.
Hence we overload).
=#

# Non-full precision printing of all floats.
Base.show(io::IO, ::MIME"text/plain", x::Float64) =
    show(IOContext(io, :compact => true), x)

# m² instead of m^2
Base.show(io::IO, ::MIME"text/plain", x::Unitful.Unitlike) =
    show(IOContext(io, :fancy_exponent => true), x)

function Base.show(io::IO, ::MIME"text/plain", x::AbstractArray{<:Quantity})
    summary(io, x)
    println(io, ":")
    Base.print_array(io, ustrip(x))
end

#=
Show summary of the type of a homogeneous unitful array.
`showarg(::Array)` is called by `summary(::Array)`, which in turn is called by
`show(::Array)`. In the string "300-element Vector{Eltype}: …", `showarg` is responsible
for the part "Vector{ElType}".
=#
function Base.showarg(
    io::IO,
    x::AbstractArray{<:Quantity{T,D,U},N},
    toplevel::Bool,
) where {T,D,U,N}
    t = typeof(x)
    alias = Base.make_typealias(t)
    arraytype = isnothing(alias) ? nameof(t) : alias[1].name
    #    For Vectors and Matrices, we don't want to use `nameof(t)`, as it returns "Array".
    io = IOContext(io, :fancy_exponent => get(io, :fancy_exponent, true))
    #    `print` doesn't have a MIME argument, so we cannot dispatch to our show(::Unitlike)
    #    above. Hence we need to set the fancy flag here.
    print(io, arraytype, "{", Quantity, "(::", T, ", ", U(), ")")
    (t <: AbstractVecOrMat && !isnothing(alias)) || print(io, ", ", N)
    #    Don't print N for Vector or Matrix.
    print(io, "}")
end

"""
    showex([io::IO = stdout,] x; nfirst = 2, nlast = 2, nsample = 2)

Print an overview of the vector `x`, by example. Show its first and last entries, and a
random sample in between.
"""
showex(        x; nfirst = 2, nlast = 2, nsample = 2) = showex(stdout, x; nfirst, nlast, nsample)
showex(io::IO, x; nfirst = 2, nlast = 2, nsample = 2) = begin
    if length(x) ≤ nfirst + nlast + nsample
        nfirst = length(x)
        nlast, nsample = 0, 0
    end
    summary(io, x)  # eg "640-element Vector{String}"
    println(io)
    all_i = 1:length(x)  # Always `Int`s
    all_ix = eachindex(x)  # Generally same, but can also be `CartesianIndex`, `Symbol`, …
    shown_i = @views vcat(
        all_i[1:nfirst],
        all_i[nfirst+1:end-nlast] |> (is -> sample(is, nsample)) |> sort,
        all_i[end-nlast+1:end],
    )
    shown_ix = all_ix[shown_i]
    ixlen = maximum(length, string.(shown_ix))
    printrow(ix) = println(io, lpad(ix, ixlen), ": ", repr(x[ix]))
    printdots() = println(io, lpad("⋮", ixlen + 2))
    first(shown_i) == first(all_i) || printdots()
    for (i, inext) in ziplongest(shown_i, shown_i[2:end])
        printrow(all_ix[i])
        isnothing(inext) || inext == i + 1 || printdots()
    end
    last(shown_i) == last(all_i) || printdots()
    return nothing
end

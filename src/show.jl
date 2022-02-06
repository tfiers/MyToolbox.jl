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

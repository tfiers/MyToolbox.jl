#=
Human friendly printing.
=#

"""No more red backgrounds in IJulia output. Also, `@info` will be less verbose."""
function prettify_logging_in_IJulia()
    global_logger(get_interactive_logger())
    redirect_stderr(stdout)
end

# The default logger in IJulia is a `SimpleLogger(stderr)`, which prints source information
# not only for `@warn` but also for `@info`. The default logger in the Julia REPL is a
# `ConsoleLogger(stdout)`, which is smarter.
get_interactive_logger() = ConsoleLogger(stdout)
    # `stdout` is a writeable global (e.g. IJulia modifies it). Hence this is a getter and
    # not a constant.


"""Like `dump` but without types, with colors, and with `:compact` printing by default."""
function dumps(io::IO, @nospecialize(x); depth = 0, skipfields = Symbol[])
    if fieldcount(typeof(x)) == 0
        printstyled(io, x, "\n", color = :light_blue)
    else
        printstyled(io, typeof(x), "\n", color = :light_black)
        depth += 1
        indent = "  "^depth
        for fieldname in fieldnames(typeof(x))
            print(io, indent, fieldname, ": ")
            if fieldname ∈ skipfields
                printstyled(io, "[skipped]", "\n", color = :light_cyan)
            else
                dumps(io, getproperty(x, fieldname); depth, skipfields)
                # No infinite recursion guard. CBA.
            end
        end
    end
end
dumps(x; kw...) = dumps(IOContext(stdout, :compact => true, :limit => true), x; kw...)


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


set_print_precision(digits = 3) = set_float_print_fmt("%.$(digits)G")

function set_float_print_fmt(fmt = "%.2f")
    fmt = Printf.Format(fmt)
    eval( :( Base.show(io::IO, x::Float64) = Printf.format(io, $fmt, x) ) )
end
# We don't specify `::MIME"text/plain"` in `show`, so that we also get compact floats in
# composite types (like when displaying a NamedTuple). Disadvantage is that we cannot use
# `show(x)` to see full float repr anymore. (One solution is to fmt with many digits).


# By default, if both a markdown and an html `show` are available, IJulia only saves the
# markdown version in the output of a cell.
# But JupyterBook does not render markdown tables in cell outputs (see displaytable.jl).
# Hence, we must give it the html-rendered version of markdown.
function output_html_too_for_md()
    empty!(IJulia.ijulia_mime_types)
    append!(IJulia.ijulia_mime_types, [
        MIME("text/plain"),
        MIME("image/svg+xml"),
        [
            MIME("image/png"),
            MIME("image/jpeg"),
        ],
        MIME("text/latex"),
        MIME("text/markdown"),
        MIME("text/html"),
    ])
end

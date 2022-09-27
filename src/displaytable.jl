
# To print hand-constructed matrixes of values
#
# PrettyTables.jl could do that as well, but:
# - its version is pinned to sth quite old by DataFrames.
# - it cannot do Markdown

struct DisplayTable
    cells   ::Matrix{Any}
    title   ::String
    to_bold ::Vector{NTuple{2,Int}}
end

# We do not specify ::MIME"text/plain", so that
# this method is also called for just `show(t)`.
function Base.show(io::IO, t::DisplayTable)
    printstyled(io, t.title, "\n\n", bold = true)
    nrows, ncols = size(t.cells)
    colwidths = get_colwidths(t.cells, mincolwidth = 2)
    for r in 1:nrows
        for c in 1:ncols
            cell = lpad(t.cells[r,c], colwidths[c] + 1)
            #   + 1, to have at least 1 padding space between columns
            bold = (r,c) ∈ t.to_bold
            printstyled(io, cell; bold)
        end
        println(io)
    end
end

function Base.show(io::IO, ::MIME"text/markdown", t::DisplayTable)
    nrows, ncols = size(t.cells)
    # Prepend two rows, for markdown table header
    nrows_md = nrows + 2
    tm = Matrix{Any}(missing, nrows_md, ncols)
    tm[3:end, :] .= t.cells
    for (r,c) in t.to_bold
        val = t.cells[r,c]
        x = strip(val)
        if x != ""
            tm[r+2, c] = "**$(x)**"
        end
    end
    for i in eachindex(tm)
        # This hould not be here -- it is Vtms perf matrix specific
        if (tm[i] isa Symbol)
            tm[i] = "`$(tm[i])`"
        end
    end
    content_colwidth = get_colwidths(t.cells)
    md_colwidths     = get_colwidths(tm)
    # no-breaking spaces, to force widths:
    tm[1, :] .= ["&nbsp; "^c for c in content_colwidth]
    tm[2, :] .= ["-"^c       for c in md_colwidths]
    tm[1,1] = t.title
    for r in 1:nrows_md
        for c in 1:ncols
            val = tm[r,c]
            print(io, "|", lpad(val, md_colwidths[c]))
        end
        println(io, "|")
    end
end

function get_colwidths(cells; mincolwidth = 3)
    cellwidths = (cells .|> string .|> length)
    colwidths = vec(maximum(cellwidths, dims = 1))
    colwidths = max.(colwidths, mincolwidth)
end

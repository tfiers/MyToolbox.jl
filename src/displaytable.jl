
# To print hand-constructed matrixes of values
#
# Todo: get rid of, and replace by PrettyTables.
# The below is no longer valid:
#
# > PrettyTables.jl could do that as well, but:
# > - its version is pinned to sth quite old by DataFrames.
# > - it cannot do Markdown
#
# It can do markdown via Text backend, and then `tf=tf_markdown`.
# And w/ a rel. recent DataFrames upgrade, we have a newer version of PrettyTables too,
# which is useable.

struct DisplayTable
    cells   ::Matrix{Any}
    title   ::String
    to_bold ::Vector{NTuple{2,Int}}

    DisplayTable(cells, title = "", to_bold = []) =
        new(cells, title, to_bold |> collect |> vec .|> Tuple)
end

# We do not specify ::MIME"text/plain", so that this method is also called for just
# `show(t)`. In principle, `show` without a mime "generally includes type information, and
# should be parseable Julia code when possible." But nah. (DataFrame also doesn't do this
# e.g). You can always use `dump`/`dumps` to see the datastructure.
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

# We prefer html over markdown, as JupyterBook does not render markdown tables in cell
# *outputs* (GitHub and Jupyter local do however).
function Base.show(io::IO, ::MIME"text/html", t::DisplayTable)
    str = repr("text/markdown", t)
    md = Markdown.parse(str)
    ht = Markdown.html(md)
    htr = replace(ht, "&amp;nbsp;" => "&nbsp;")  # Undo the escaping
    print(io, htr)
end

function Base.show(io::IO, ::MIME"text/markdown", t::DisplayTable)
    nrows, ncols = size(t.cells)
    # Prepend two rows, for markdown table header
    nrows_md = nrows + 2
    mc = Matrix{Any}(missing, nrows_md, ncols)
    mc[3:end, :] .= t.cells
    for (r,c) in t.to_bold
        val = t.cells[r,c]
        x = strip(val)
        if x != ""
            mc[r+2, c] = "**$(x)**"
        end
    end
    for i in eachindex(mc)
        # This hould not be here -- it is Vtms perf matrix specific
        if (mc[i] isa Symbol)
            mc[i] = "`$(mc[i])`"
        end
    end
    content_colwidth = get_colwidths(t.cells)
    md_colwidths     = get_colwidths(mc)
    # no-breaking spaces, to force widths:
    mc[1, :] .= ["&nbsp; "^c for c in content_colwidth]
    mc[2, :] .= ["-"^c       for c in md_colwidths]
    mc[1,1] = t.title
    for r in 1:nrows_md
        for c in 1:ncols
            val = mc[r,c]
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

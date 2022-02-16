@reexport using DataFrames
@reexport using PrettyTables

# See https://dataframes.juliadata.org/stable/lib/functions/#Base.show
# and https://ronisbr.github.io/PrettyTables.jl/stable/man/usage/
printsimple(df::DataFrame; kw...) = show(
    move_units_to_header(df);
    summary = false,
    eltypes = false,
    show_row_number = false,
    formatters = ft_printf("%.3g"),
    alignment = :l,
    kw...
)

function move_units_to_header!(df::DataFrame)
    for (name, col) in zip(names(df), eachcol(df))
        if eltype(col) <: Quantity
            unitstr = repr(MIME("text/plain"), unit(first(col)))
            df[!, name] = ustrip(col)
            rename!(df, name => "$name ($unitstr) ")  # one space extra right pad.
        end
    end
    return df
end

move_units_to_header(df::DataFrame) = move_units_to_header!(copy(df))

@reexport using DataFrames
@reexport using PrettyTables

# See https://dataframes.juliadata.org/stable/lib/functions/#Base.show
# and https://ronisbr.github.io/PrettyTables.jl/stable/man/usage/
printsimple(df::DataFrame; kw...) = show(
    df;
    summary = false,
    eltypes = false,
    show_row_number = false,
    formatters = ft_printf("%.3g"),
    alignment = :l,
    kw...
)

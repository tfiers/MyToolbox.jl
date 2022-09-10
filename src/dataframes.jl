@reexport using DataFrames
@reexport using PrettyTables

# See https://dataframes.juliadata.org/stable/lib/functions/#Base.show
# and https://ronisbr.github.io/PrettyTables.jl/stable/man/usage/
printsimple(
    df::DataFrame;
    summary         = false,
    eltypes         = false,
    show_row_number = false,
    formatters      = ft_printf("%.3g"),
    alignment       = :l,                      # for text, not numbers
    kw...
) = show(df; summary, eltypes, show_row_number, formatters, alignment, kw...)

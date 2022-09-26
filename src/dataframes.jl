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


function disp(df::DataFrame, rows = 100, cols = 400)
    l = ENV["LINES"]
    c = ENV["COLUMNS"]

    ENV["LINES"] = rows
    ENV["COLUMNS"] = cols
    display(df)

    ENV["LINES"] = l
    ENV["COLUMNS"] = c
    return nothing
end

# for piping
disp(rows = 100, cols = 400) = (df -> disp(df, rows, cols))

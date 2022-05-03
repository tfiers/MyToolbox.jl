
"""
    @alias new = original

Define `const new = original` and attach `original`'s docstring to `new`.
"""
macro alias(expr)
    expr.head == :(=) || error("must be an assignment expression")
    new, original = expr.args
    return quote
        @doc (@doc $original)
        const $(esc(new)) = $(esc(original))
    end
end


"""
    @withfb "Reticulating splines" slow_function()

Give user feedback: what is happening when the program hangs; and when is it done.
"""
macro withfb(description, expr)
    return quote
        print($(esc(description)) * " … ")
        flush(stdout)
        $(esc(expr))
        println("done")
    end
end

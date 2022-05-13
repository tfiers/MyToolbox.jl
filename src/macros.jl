
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

Print the given description of what is happening before running some slow code;
run the code; and print when it is done (including time taken, if it's not negligible).

The goal is to give user feedback on what is happening when the program hangs.
"""
macro withfb(description, expr)
    return quote
        print($(esc(description)), " … ")
        flush(stdout)
        t0 = time()
        $(esc(expr))
        time_taken = time() - t0
        print("done")
        if time_taken > 0.05  # seconds
            @printf " (%.1f s)" time_taken
        end
        println()
    end
end

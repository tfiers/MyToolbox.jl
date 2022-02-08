
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
    @exportn x = …

Assign and then export the name `x`.
"""
macro exportn(expr)
    uexpr = _unwrap_macrocalls(expr)  # so we can combine `@exportn @alias x = …`
    if uexpr.head == :(=)        assignment = uexpr
    elseif uexpr.head == :const  assignment = only(uexpr.args)
    else                         error("must be an assignment expression")
    end
    name = first(assignment.args)
    return quote
        $(esc(expr))
        export $name
    end
end

function _unwrap_macrocalls(expr)
    while expr.head == :macrocall
        expr = last(expr.args)
    end
    return expr
end

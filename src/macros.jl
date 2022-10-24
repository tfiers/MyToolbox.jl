
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
macro withfb(description, expr, thr = 0.05)
    return quote
        print($(esc(description)), " … ")
        flush(stdout)
        t0 = time()
        $(esc(expr))
        time_taken = time() - t0
        print("done")
        if time_taken > $thr  # seconds
            @printf " (%.1f s)" time_taken
        end
        println()
    end
end


"""
Creates a NamedTuple containing the variables defined in the given block.

With this macro, functions that output a large namedtuple (with values that depend on each
other) become more maintainable and a tad shorter/DRYer.

Concretely,

    f(x) = @NT begin
        a = x + 3
        b = a * x
    end

is rewritten as

    f(x) = begin
        a = x + 3
        b = a * x
        (; a, b)
    end

This is similar to using `NamedTuple(Base.@locals)` (with a `let` block), but that breaks
type inference; this macro does not.

If you want to use only a select number of variables for the namedtuple, mark their
assignment statements with `@out`:

    @NT begin
        @out a = x + 3
        b = a * x
        @out c = a + b
    end
"""
macro NT(block)
    @assert block.head == :block
    lines = [e for e in block.args if !isa(e, LineNumberNode)]
    marked_lines = [l for l in lines if is_macrocall(l, "@out")]
    if isempty(marked_lines)
        # No `@out` statements found.
        statements = lines
    else
        # Extract expressions after `@out` calls.
        statements = [extract_macro_arg(line) for line in marked_lines]
    end
    names = mapreduce(get_assigned_names, vcat, statements)
    push!(block.args, :( (; $(names...)) ))  # Add namedtuple creation as last line to block.
    return esc(block)  # `esc` needed, to avoid gensym variables, so type inference is possible.
end

"""For use within `@NT`; Mark this statement for inclusion in the namedtuple."""
macro out(line)
    return esc(line)
end

function get_assigned_names(line::Expr)
    if is_macrocall(line, "@unpack")
        # :( @unpack x,y = obj )
        line = extract_macro_arg(line)
    end
    if line.head != :(=)
        return no_names  # Don't get names from lines like :( y .= 3 ) or :( println(x) ).
        # We also silently ignore line-wide macros (besides @unpack) here.
        # Also missed: if-else, `function` defs;
        # more: https://docs.julialang.org/en/v1/devdocs/ast/
    end
    lhs, rhs = line.args
    if (lhs isa Expr) && (lhs.head == :ref)
        return no_names  # Don't get names from lines like :( A[1] = 3 )
    else
        return get_names(lhs)
    end
end
const no_names = Symbol[]

get_names(e::Symbol) = [e]  # :( x = f(y) )
get_names(e::Expr) =        # :( x,y = f(z) )
    if e.head == :tuple
        # Recursion needed in :( a,(b,c) = [1,[2,3]] ) case
        mapreduce(get_names, vcat, e.args)
    elseif e.head == :...
        # `b` in :( a, b... = [1,2,3] )
        get_names(only(e.args))
    elseif e.head == :(::)
        # :( x::Float64 = 8 )
        [e.args[2]]
    else
        error("Unrecognized left-hand-side expression: $e")
    end

is_macrocall(e::Expr) = (e.head == :macrocall)
is_macrocall(e::Expr, name::String) = is_macrocall(e) && (e.args[1] == Symbol(name))
extract_macro_arg(mc::Expr) = only(mc.args[3:end])

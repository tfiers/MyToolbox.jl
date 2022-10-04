using PyPlot

function savefig(fname; subdir = nothing)
    "figdir" in keys(ENV) || @error "Environment variable `figdir` not set."
    dir = ENV["figdir"]
    isnothing(subdir) || (dir = joinpath([dir, subdir]))
    isdir(dir) || mkpath(dir)
    plt.savefig(joinpath([dir, fname]))
end

# Hi-def ('retina') figures in notebook. [https://github.com/JuliaLang/IJulia.jl/pull/918]
function IJulia.metadata(x::PyPlot.Figure)
    w, h = (x.get_figwidth(), x.get_figheight()) .* x.get_dpi()
    return Dict("image/png" => Dict("width" => 0.5 * w, "height" => 0.5 * h))
end

"""
When using a sysimg with PyPlot in it, PyPlot's `__init__` gets called before IJulia is
initialized. As a result, figures do not get automatically displayed in the notebook.
(https://github.com/JuliaPy/PyPlot.jl/issues/476).
Calling this method after IJulia is initialized fixes that.

To temporarily disable auto-display of figures in a notebook,
set `PyPlot.isjulia_display[] = false`.
"""
function autodisplay_figs_in_sysimg()
    if (isdefined(Main, :PyPlot) && isdefined(Main, :IJulia) && Main.IJulia.inited
        && (Main.PyPlot.isjulia_display[] == false)
    )
        Main.PyPlot.isjulia_display[] = true
        Main.IJulia.push_preexecute_hook(Main.PyPlot.force_new_fig)
        Main.IJulia.push_postexecute_hook(Main.PyPlot.display_figs)
        Main.IJulia.push_posterror_hook(Main.PyPlot.close_figs)
    end
end


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

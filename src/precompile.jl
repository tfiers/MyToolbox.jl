function _precompile_()
    # Dependencies
    t1 = f"Hello {3.2:.2f}"
    @showprogress 0.1 "" (
    for i in 1:3
        nothing
    end)
    t2 = @match "" begin
        "" => 1
    end
    t3 = (x = 1,)
    @set (t3.x = 2)
    @unpack x = t3

    # Self
    t4 = @NT begin
        x = 1
        y = x
    end
    dt = DisplayTable([t1 t2; t3 t4])
    show(devnull, dt)
    show(devnull, "text/html", dt)
    iv = idvec(:A, :B => 1)
    dumps(devnull, iv)
    showsome(devnull, iv)
    ls = linspace(0, 10, num=5)
    it = ziplongest(ls, 1:2)
    # @alias rose = "name"  # `const` in function not allowed.
    @withfb "ignore this" chain(it, 1:2)

    return (t1, t2, t3, t4, dt, iv, ls)
end

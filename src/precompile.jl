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
    # devnull < dumps, showsome, withfb, displaytable mayb
    # aren't those already precompiled??

    return (t1, t2, t3, t4)
end

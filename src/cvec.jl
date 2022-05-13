
@alias CVec = ComponentVector

"""
    idvec(first_group_name = first_group_size, …)

Example:

    idvec(A = 4, B = 2, …)
    ↓
    CVec(A = [1,2,3,4], B = [5,6])

Build a `ComponentVector` (CVec) with the given group names and as many elements per group
as specified. Each element gets a unique ID within the CVec, which is also its index in the
CVec.

Specify `nothing` as the group size for a scalar element. Example:

    idvec(A = nothing, B = 1)
    ↓
    CVec(A = 1, B = [2])
"""
function idvec(; kw...)
    cvec = CVec(; (name => _expand(val) for (name, val) in kw)...)
    cvec .= 1:length(cvec)
    return cvec
end
const _temp = 0  # value does not matter; it gets overwritten by `1:length(cvec)` above.
_expand(val::Nothing) = _temp
_expand(val::Integer) = fill(_temp, val)
_expand(val::CVec)    = val              # allow nested idvecs

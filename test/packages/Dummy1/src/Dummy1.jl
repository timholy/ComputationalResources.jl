module Dummy1

using ComputationalResources

function __init__()
    push!(LOAD_PATH, dirname(@__FILE__))
    if haveresource(ArrayFireLibs)
        @eval using Dummy1AF
    end
    pop!(LOAD_PATH)
end

foo(::CPU1) = true

end

using ComputationalResources
using Base.Test

push!(LOAD_PATH, joinpath(dirname(@__FILE__), "packages"))

import Dummy1

@test Dummy1.foo(CPU1())
@test_throws MethodError Dummy1.foo(ArrayFireLibs())

addresource(ArrayFireLibs)
@test haveresource(ArrayFireLibs)

reload("Dummy1")

@test Dummy1.foo(CPU1())
@test Dummy1.foo(ArrayFireLibs())

rmresource(ArrayFireLibs)

reload("Dummy1")

@test Dummy1.foo(CPU1())
@test_throws MethodError Dummy1.foo(ArrayFireLibs())

pop!(LOAD_PATH)

@test isa(CPUThreads(), AbstractCPU{Void})
@test isa(CUDALibs(), AbstractResource{Void})
@test isa(OpenCLLibs(), AbstractResource{Void})

nothing

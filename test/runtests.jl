using ComputationalResources
using Test

@testset "ComputationalResources" begin
    @testset "Settings" begin
        for r in (CPU1(5), CPUThreads(5), CPUProcesses(5), ArrayFireLibs(5), CUDALibs(5), OpenCLLibs(5))
            for T in (CPU1, CPUThreads, CPUProcesses, ArrayFireLibs, CUDALibs, OpenCLLibs)
                r1 = T(r)
                @test r1.settings === 5
            end
        end

        @test isa(CPUThreads(), AbstractCPU{Nothing})
        @test isa(CPUProcesses(), AbstractCPU{Nothing})
        @test isa(CUDALibs(), AbstractResource{Nothing})
        @test isa(OpenCLLibs(), AbstractResource{Nothing})
    end

    @testset "Dummy1" begin
        push!(LOAD_PATH, joinpath(dirname(@__FILE__), "packages"))

        @eval import Dummy1

        @test Dummy1.foo(CPU1())
        @test_throws MethodError Dummy1.foo(ArrayFireLibs())

        addresource(ArrayFireLibs)
        @test haveresource(ArrayFireLibs)

        Main.Dummy1.__init__()

        @test Main.Dummy1.foo(CPU1())
        @test Main.Dummy1.foo(ArrayFireLibs())

        rmresource(ArrayFireLibs)

        include("packages/Dummy1/src/Dummy1.jl")

        @test Main.Dummy1.foo(CPU1())
        @test_throws MethodError Main.Dummy1.foo(ArrayFireLibs())

        pop!(LOAD_PATH)
    end
end

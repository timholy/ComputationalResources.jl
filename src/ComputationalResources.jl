module ComputationalResources

export
    # Resources
    AbstractResource,
    AbstractCPU,
    ArrayFireLibs,
    CPU1,
    CPUThreads,
    CPUProcesses,
    CUDALibs,
    OpenCLLibs,
    # Settings
    TileSize,
    # functions
    addresource,
    haveresource,
    rmresource

### Resources

"""
    AbstractResource

The abstract supertype of all computational resources.
"""
abstract type AbstractResource{T} end

"""
    AbstractCPU

An abstract type indicating that computation should be performed using
the CPU.
"""
abstract type AbstractCPU{T} <: AbstractResource{T} end

"""
    CPU1()
    CPU1(settings)

Indicate that a computation should be performed using the CPU in single-threaded mode.
Optionally pass in an object specifying algorithmic settings.

# Examples:
```julia
filter(CPU1(), image, kernel)
filter(CPU1(TileSize(64,8)), image, kernel)
```
"""
struct CPU1{T} <: AbstractCPU{T}
    settings::T
end
CPU1() = CPU1(nothing)
CPU1(r::AbstractResource) = CPU1(r.settings)

"""
    CPUThreads()
    CPUThreads(settings)

Indicate that a computation should be performed using the CPU in multi-threaded mode.
Optionally pass in an object specifying algorithmic settings.

# Examples:
```julia
filter(CPUThreads(), image, kernel)
filter(CPUThreads(TileSize(64,8)), image, kernel)
```
"""
struct CPUThreads{T} <: AbstractCPU{T}
    settings::T
end
CPUThreads() = CPUThreads(nothing)
CPUThreads(r::AbstractResource) = CPUThreads(r.settings)

"""
    CPUProcesses()
    CPUProcesses(settings)

Indicate that a computation should be performed using the CPU in multi-process mode.
Processes should be added with addprocs() or julia started with `julia -p N`.
Processes must communicate using distributed memory operations such as remote refrences.
Optionally pass in an object specifying algorithmic settings.

# Examples:
```julia
filter(CPUProcesses(), image, kernel)
filter(CPUProcesses(TileSize(64,8)), image, kernel)
```
"""
struct CPUProcesses{T} <: AbstractCPU{T}
    settings::T
end
CPUProcesses() = CPUProcesses(nothing)
CPUProcesses(r::AbstractResource) = CPUProcesses(r.settings)

"""
    ArrayFireLibs()
    ArrayFireLibs(settings)

Indicate that computation should be performing using the ArrayFire libraries.
Optionally pass in an object specifying algorithmic settings.

# Examples:
```julia
filter(ArrayFireLibs(), image, kernel)
filter(ArrayFireLibs(backend), image, kernel)
```
"""
struct ArrayFireLibs{T} <: AbstractResource{T}
    settings::T
end
ArrayFireLibs() = ArrayFireLibs(nothing)
ArrayFireLibs(r::AbstractResource) = ArrayFireLibs(r.settings)

"""
    CUDALibs()
    CUDALibs(settings)

Indicate that computation should be performing using the CUDA libraries.
Optionally pass in an object specifying algorithmic settings.

# Examples:
```julia
filter(CUDALibs(), image, kernel)
filter(CUDALibs(backend), image, kernel)
```
"""
struct CUDALibs{T} <: AbstractResource{T}
    settings::T
end
CUDALibs() = CUDALibs(nothing)
CUDALibs(r::AbstractResource) = CUDALibs(r.settings)

"""
    OpenCLLibs()
    OpenCLLibs(settings)

Indicate that computation should be performing using the OpenCL libraries.
Optionally pass in an object specifying algorithmic settings.

# Examples:
```julia
filter(OpenCLLibs(), image, kernel)
filter(OpenCLLibs(backend), image, kernel)
```
"""
struct OpenCLLibs{T} <: AbstractResource{T}
    settings::T
end
OpenCLLibs() = OpenCLLibs(nothing)
OpenCLLibs(r::AbstractResource) = OpenCLLibs(r.settings)


### Settings

"""
    TileSize(dims)

Request that an array computation be performed using tiles (blocks) of size `dims`.
"""
struct TileSize{N}
    dims::NTuple{N,Int}
end

# Hold the available resources, allows packages to control loading of code
const resources = Set{Type}([CPU1])

"""
    addresource(T)

Add `T` to the list of available resources. For example,
`addresource(OpenCLLibs)` would indicate that you have a GPU and the
OpenCL libraries installed.
"""
addresource(::Type{T}) where {T<:AbstractResource} = push!(resources, T)

"""
    rmresource(T)

Remove `T` from the list of available resources. For example,
`rmresource(OpenCLLibs)` would indicate that any future package loads
should avoid loading their specializations for OpenCL.
"""
rmresource(::Type{T}) where {T<:AbstractResource} = delete!(resources, T)

"""
    haveresource(T)

Returns `true` if `T` is an available resource. For example,
`haveresource(OpenCLLibs)` tests whether the `OpenCLLibs` have been
added as an available resource. This function is typically used inside
a module's `__init__` function.

# Example:

```julia
# The __init__ function for MyPackage:
function __init__()
    ...  # other initialization code, possibly setting the LOAD_PATH
    if haveresource(OpenCLLibs)
        @eval using MyPackageCL  # a separate module containing OpenCL implementations
    end
    # Put additional resource checks here
    ...  # other initialization code, possibly cleaning up the LOAD_PATH
end
```
"""
haveresource(::Type{T}) where {T<:AbstractResource} = T ∈ resources

"""
ComputationalResources makes it possible to dispatch to different methods that employ different computational resources. The exported resources are:

- `CPU1` (single-threaded computation)
- `CPUThreads` (multi-threaded computation)
- `CPUProcesses` (multi-process computation)
- `ArrayFireLibs` (using the [ArrayFire package](https://github.com/JuliaComputing/ArrayFire.jl)
- `CUDALibs` (GPU computation using NVIDIA's CUDA libraries)
- `OpenCLLibs` (GPU computation using the OpenCL libraries)

There are also functions that interact with package initialization
machinery to control the availability of supported methods:

- `addresource(T)`: request newly-loaded packages to support resource `T`
- `rmresource(T)`: stop asking newly-loaded packages to support resource `T`
- `haveresource(T)`: test whether resource `T` has been requested
"""
ComputationalResources

end # module

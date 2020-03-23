# ComputationalResources

[![Build Status](https://travis-ci.org/timholy/ComputationalResources.jl.svg?branch=master)](https://travis-ci.org/timholy/ComputationalResources.jl)

[![codecov.io](http://codecov.io/github/timholy/ComputationalResources.jl/coverage.svg?branch=master)](http://codecov.io/github/timholy/ComputationalResources.jl?branch=master)

A Julia package for choosing resources (hardware, libraries,
algorithms) for performing computations. It exports a set of types
that allow you to dispatch to different methods depending on the
selected resources. It also includes simple facilities that help
package authors manage the loading of code in a way that depends on
resource availability and user choice.

# Resources

This package exports the following types of resources:

- CPU1 (single-threaded computation)
- CPUThreads (multi-threaded computation)
- CPUProcesses (multi-process computation)
- ArrayFireLibs (using the [ArrayFire package](https://github.com/JuliaComputing/ArrayFire.jl))
- CUDALibs (GPU computation using NVIDIA's CUDA libraries)
- OpenCLLibs (GPU computation using the OpenCL libraries)

Algorithm selection is performed by passing a resource instance as an
argument (conventionally, the first argument) to a function, where
`CPU1()` is the typical default. Instances of these types may
optionally store additional settings that you can customize; for
example you could define a `TimeOut` type:

```julia
struct TimeOut
    seconds::Float64
end
```

and then call some algorithm as

```julia
optimize(CPU1(TimeOut(3)), f, x)
```

As a package author, you could write `optimize` to check for the
timeout value and terminate early once this time has been exceeded.

# Usage as a user

Begin your session with

```julia
using ComputationalResources
```

Then choose any resources you have available, for example:

```julia
addresource(ArrayFireLibs)
```

It's important to do this before you load any packages supporting
`ArrayFire`-specific implementations; otherwise, calls such as

```
filter(ArrayFireLibs(), b, a, data)
```

are likely to throw a `MethodError` because the relevant
specializations will not have been loaded.

If you'd like to make your selection of available resources automatic,
you can add such lines to your `.juliarc.jl` file.

# Usage as a package author

You can make the loading of code dependent upon the resources selected
by the user. We'll use the "Dummy" package as an example (see also the
`test/packages` folder for additional examples). This package could
have the following file structure:

```
src/
  Dummy.jl
  DummyAF.jl
  ...
test/
  ...
```

where `...` means additional files. `Dummy.jl` might start like this:

```julia
module Dummy

using ComputationalResources

# You need an __init__ function that will manage the loading of
# sub-modules that implement specializations for different
# computational resources
function __init__()
    # Enable `using` to load additional modules in this folder
    push!(LOAD_PATH, dirname(@__FILE__))
    # Now check for any resources that your package supports
    if haveresource(ArrayFireLibs)
        # User has indicated support for the ArrayFire libraries, so load your relevant code
        @eval using DummyAF
    end
    # Put additional resource checks here
    # Don't forget to clean up!
    pop!(LOAD_PATH)
end

# Now define the methods you'll export, using single-threaded CPU
# computations as the "foundation"
function foo(resource::CPU1, args...)
    # awesome algorithm goes here
end

# Typically you should select a default resource
foo(args...) = foo(CPU1(), args...)

end
```

Your `DummyAF` module is implemented in `DummyAF.jl`, which might look like this:

```julia
module DummyAF

using ComputationalResources, Dummy, ArrayFire

function Dummy.foo(resource::ArrayFireLibs, args...)
    # specialization for the same computation, but using the ArrayFire libraries instead
end

end
```

Note that the `ArrayFire` package was loaded by `DummyAF` but not by
`Dummy`; as a consequence, users who do not have this package
installed will not experience any errors. Assuming it's optional, you
should *not* add `ArrayFire` to your package's `REQUIRE` file.

VERSION < v"0.7.0-beta2.199" && __precompile__()

module Dummy1AF

using ComputationalResources, Dummy1

Dummy1.foo(::ArrayFireLibs) = true

end

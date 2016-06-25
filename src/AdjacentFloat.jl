module AdjacentFloat

typealias SysFloat Union{Float64, Float32}

export prevFloat, nextFloat, nFloatsSeparate, nextNearerToZero, nextAwayFromZero

include("adjacentFloats.jl")

end # module

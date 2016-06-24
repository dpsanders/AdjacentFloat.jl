module AdjacentFloat

!isdefined(Float) && typealias Float AbstractFloat;

export prevFloat, nextFloat, nFloatsSeparate, nextNearerToZero, nextAwayFromZero

include("adjacentFloats.jl")

end # module

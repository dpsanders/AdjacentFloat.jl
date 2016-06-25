module AdjacentFloat

!isdefined(Main,:Float) 
    typealias Float AbstractFloat
else
    typealias Float Main.Float
end    

export prevFloat, nextFloat, nFloatsSeparate, nextNearerToZero, nextAwayFromZero

include("adjacentFloats.jl")

end # module

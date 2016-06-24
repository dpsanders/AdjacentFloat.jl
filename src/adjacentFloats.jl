#=
  These routines return +/-Inf when given +/-Inf.
  That differs from nextfloat(-Inf) == -realmax(), prevfloat(Inf) == realmax()
  (prevfloat(Inf)==Inf makes more sense to me, and likely is more helpful).
  And steps twice when given values of very small magnitude (see paper).
  The alternative implementation, converting to [U]Int and adding/subtracting 1,
  returns NaN when given +/-Inf -- and checking for Inf adds branching. 
  ref:
  'Predecessor and Successor In Rounding To Nearest' by Siegried M. Rump
  "The routines deliver the exact answer except for a small range near underflow,
   in which case the true result is overestimated by eta [the value added/subtracted below]."
=#
# exact for |x| > 8.900295434028806e-308
nextNearerToZero(x::Float64)   = (0.9999999999999999*x)-5.0e-324 # (x-1.1102230246251568e-16*x)-5.0e-324 
nextAwayFromZero(x::Float64)   = (1.0000000000000002*x)+5.0e-324 # (x+1.1102230246251568e-16*x)+5.0e-324
# exact for |x| > 4.814825f-35
nextNearerToZero(x::Float32)   = (0.99999994f0*x)-1.435f-42      # (x-5.960465f-8*x)-1.435f-42
nextAwayFromZero(x::Float32)   = (1.00000010f0*x)+1.435f-42      # (x+5.960465f-8*x)+1.435f-42
# the multiplicative formulation for Float16 is exact for |x| > Float16(0.25)
# which is quite coarse, we do not use that here
nextNearerToZero(x::Union{BigFloat,Float16}) = signbit(x) ? nextfloat(x) : prevfloat(x)
nextAwayFromZero(x::Union{BigFloat,Float16}) = signbit(x) ? prevfloat(x) : nextfloat(x)

@inline nextFloat{T<:AbstractFloat}(x::T) = signbit(x) ? nextNearerToZero(x) : nextAwayFromZero(x)
@inline prevFloat{T<:AbstractFloat}(x::T) = signbit(x) ? nextAwayFromZero(x) : nextNearerToZero(x)

@inline nextFloat(x::Union{BigFloat,Float16}) = nextfloat(x)
@inline prevFloat(x::Union{BigFloat,Float16}) = prevfloat(x)

function nextFloat{T<:AbstractFloat}(x::T, n::Int)
    if !signbit(n)
        for i in 1:n
            x = nextFloat(x)
        end
    else
        x = prevFloat(x,-n)
    end
    x
end

function prevFloat{T<:AbstractFloat}(x::T, n::Int)
    if !signbit(n)
        for i in 1:n
            x = prevFloat(x)
        end
    else
        x = nextFloat(x,-n)
    end
  x
end

for (F,U,I) in ((:Float16,:UInt16,:Int16), (:Float32,:UInt32,:Int32), (:Float64,:UInt64,:Int64))
  @eval begin
    function nFloatsSeparate{T<:$F}(a::T, b::T)
      isneg = (a > b)
      a,b = minmax(a,b)
    
      if signbit(a) == signbit(b)
        if signbit(a)
           z = reinterpret($U,abs(a))-reinterpret($U,abs(b))
        else
           z = reinterpret($U,b)-reinterpret($U,a)
        end
      else
        z = reinterpret($U,b)+reinterpret($U,-a)+one($U)
      end
    
      if z > reinterpret($U, typemax($I))
        throw(ArgumentError(string("separation exceeds typemax(",$I,")")))
      else
        isneg ? -reinterpret($I,z) : reinterpret($I,z)
      end
    end
  end
end

#= presumes xpa == frexp(a)[2] == frexp(b)[2]
function nFloatsSeparate{T<:Float64}(a::T, b::T,xpa::Int)
    isneg = a > b
    x,y = minmax(a,b)
    z = floor(Int64, ((y-x)/2^xpa)*2^53)
    isneg ? -z : z
end
=#

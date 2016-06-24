## AdjacentFloat
fast versions of nextfloat(), prevfloat(), and closely related functions
```ruby
                                                        Jeffrey Sarnoff © 2016-Mar-22 at New York
```

### Use
```julia
using AdjacentFloat

nextFloat(Float16(1)), nextFloat(1.0f0), nextFloat(1.0)
Float16(1.001), 1.0000001f0, 1.0000000000000002

prevfloat(prevfloat(1.0f0)) == prevFloat(1.0f0, 2)
true

nFloatsSeparate(1.0, nextFloat(1.0,100))
100

```

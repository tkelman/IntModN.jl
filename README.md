[![Build
Status](https://travis-ci.org/andrewcooke/IntModN.jl.png)](https://travis-ci.org/andrewcooke/IntModN.jl)
[![Coverage Status](https://coveralls.io/repos/andrewcooke/IntModN.jl/badge.svg)](https://coveralls.io/r/andrewcooke/IntModN.jl)
[![IntModN](http://pkg.julialang.org/badges/IntModN_release.svg)](http://pkg.julialang.org/?pkg=IntModN&ver=release)

# IntModN.jl

A pragmatic (meaning incomplete, and written by someone who needed
this before he fully understood it) library for doing modular
arithmetic.

The aim is not to encapsulate a large amount of theory, or to describe
the relationships between different structures, but to enable
arithmetic on various types, motivated largely by the practical needs
of crypto code.

Incomplete; pull requests welcome.

## Examples

See the
[tests](https://github.com/andrewcooke/IntModN.jl/blob/master/src/Tests.jl).

### Simultaneous Equations

Answering [this
question](http://math.stackexchange.com/questions/169921/how-to-solve-system-of-linear-equations-of-xor-operation) (in GF(2)):

```
julia> using IntModN

@zfield 2 begin
    A = [1 1 1 0; 
         1 1 0 1;
         1 0 1 1;
         0 1 1 1]
    b = [1, 1, 0, 1]
    x = A\b
    @assert x == [0, 1, 0, 0]
end
```

### Polynomial Arithmetic

```
julia> x = X(GF2)
ZP(ZField{2,Int64},1,0)

julia> a = x^3 + x^2 + 1
ZP(ZField{2,Int64},1,1,0,1)

julia> b = x^2 + 1
ZP(ZField{2,Int64},1,0,1)

julia> p, q = divrem(a, b)
(ZP(ZField{2,Int64},1,1),ZP(ZField{2,Int64},1,0))

julia> println(p * b + q)
x^3 + x^2 + 1 mod 2
```

### Factor Rings

The multiplication [described
here](http://en.wikipedia.org/wiki/Finite_field_arithmetic#Rijndael.27s_finite_field):

```
julia> rijndael = x^8 + x^4 + x^3 + x + 1
ZP(ZField{2,Int64},1,0,0,0,1,1,0,1,1)

julia> print(FR(x^7 + x^6 + x^3 + x, rijndael) * FR(x^6 + x^4 + x + 1, rijndael))
1 mod x^8 + x^4 + x^3 + x + 1 mod 2
```

### Fast Polynomials in GF(2)

The examples above could have used any modulus.  I chose GF(2) only
because it is common.

However, the following works only in GF(2) (the trade-off for the lack
of flexibility is speed and compactness - these are encoded as bit
patterns):

```
julia> x = GF2X(Uint8)
GF2Poly{Uint8}(2)

julia> a = x^3 + x^2 + 1
GF2Poly{Uint8}(13)

julia> b = x^2 + 1
GF2Poly{Uint8}(5)

julia> p, q = divrem(a, b)
(GF2Poly{Uint8}(3),GF2Poly{Uint8}(2))

julia> @assert a == p * b + q
```

And you can also use these with factor rings:

```
julia> x = GF2X(Uint)
GF2Poly{UInt64}(2)

julia> rijndael = x^8 + x^4 + x^3 + x + 1
GF2Poly{UInt64}(283)

julia> print(FR(x^7 + x^6 + x^3 + x, rijndael) * FR(x^6 + x^4 + x + 1, rijndael))
1 mod x^8 + x^4 + x^3 + x + 1 mod 2
```

However, note that `rinjdael` here requires 9 bits of storage; there is no
representation with an implicit msb.

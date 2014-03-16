
# equality and speed tests for ZPoly, GF2Poly, and Poly

using Polynomial, IntModN

import Base: promote_rule, convert


convert{T}(::Type{ZPoly{T}}, p::Poly{T}) = ZP(p.a)
# cannot use promotion with poly as not a Number
=={T}(a::ZPoly{T}, b::Poly{T}) = a == convert(ZPoly{T}, b)
=={T}(a::GF2Poly{T}, b::Poly{ZField{2,T}}) = convert(ZPoly{ZField{2,T}}, a) == convert(ZPoly{ZField{2,T}}, b)
=={T}(a::Poly{T}, b::ZPoly{T}) = b == convert(ZPoly{T}, a)
=={T}(a::Poly{ZField{2,T}}, b::GF2Poly{T}) = convert(ZPoly{ZField{2,T}}, a) == convert(ZPoly{ZField{2,T}}, b)



function make_random(deg)
    T = ZField{2,Uint}
    a = rand!(T, Array(T, rand(0:deg+1)))
    p = ZP(a)
    convert(GF2Poly{Uint}, p), p, Poly(a)
end

function make_randoms(n, deg)
    a = (GF2Poly{Uint}, ZPoly{ZField{2,Uint}}, Poly{ZField{2,Uint}})[]
    for _ in 1:n
        push!(a, make_random(deg))
    end
    (a, (GF2Poly{Uint}, ZPoly{ZField{2,Uint}}, Poly{ZField{2,Uint}}))
end

function test_op(a, idx, op, T)
    for i in 1:length(a)
        for j in 1:length(a)
            if a[i][1] > a[j][1] && a[j][1] != zero(T[1])  # no short cct
                op(a[i][idx], a[j][idx])
            end
        end
    end
end

function do_timing(n, deg)

    # warm up
    a, T = make_randoms(10, deg)
    for op in (+, -, *, /, %)
        for idx in 1:3
            test_op(a, idx, op, T)
        end
    end

    a, T = make_randoms(n, deg)
    println(a[1])
    println(a[2])
#    for op in (+, -, *, /, %)
    for op in (/, %)
        println("\n$op")
        for idx in 1:3
            @time test_op(a, idx, op, T)
        end
    end
end

do_timing(100, 8)


function test_eq(a, T, op)
    for i1 in 1:length(a)
        for i2 in 1:length(a)
            for t1 in 1:length(T)
                p1 = a[i1][t1]
                q1 = a[i2][t1]
                for x in op
                    r1 = nothing
                    try
                        r1 = x(p1, q1)
                    catch
                    end
                    for t2 in 1:length(T)
                        println("test $i1 $i2 $(T[t1]) $(T[t2]) $x")
                        p2 = a[i1][t2]
                        q2 = a[i2][t2]
                        r2 = nothing
                        try
                            r2 = x(p2, q2)
                        catch
                        end
                        if r1 != r2
                            println("($p1) $x ($q1)")
                            println("r1  $(typeof(r1))  $(r1)")
                            println("($p2) $x ($q2)")
                            println("r2  $(typeof(r2))  $(r2)")
                        end
                        @assert r1 == r2
                    end
                end
            end
        end
    end
end

function do_eq(n, deg)
    a, T = make_randoms(n, deg)
    test_eq(a, T, (+, -, *, /, %))
end

do_eq(10, 8)
module AutoAligns

import Base: position, print, println

export left, right, center, AutoAlign

abstract Alignment

type Left <: Alignment end
const left = Left()
align(::Left, s::AbstractString, width::Int) = rpad(s, width)

type Right <: Alignment end
const right = Right()
align(::Right, s::AbstractString, width::Int) = lpad(s, width)

type Center <: Alignment end
const center = Center()
function align(::Center, s::AbstractString, width::Int)
    len = length(s)
    @assert len <= width
    lpad(rpad(s, len+floor(Int, (width-len)/2)), width)
end

get_alignment(a::Alignment, pos::Int) = a

function get_alignment(a::AbstractVector, pos::Int)
    if length(a) < pos
        a[end]
    else
        a[pos]
    end
end

function get_alignment(a::Dict, pos::Int)
    get(a, pos) do
        a[:default]
    end
end

type AutoAlign
    alignment
    table
    widths
    function AutoAlign(; alignment=left)
        table = Vector{Vector}()
        push!(table, Vector())
        new(alignment, table, Vector{Int}())
    end
end

"""
Get the position of the next item that would be printed.
"""
position(aa::AutoAlign) = length(aa.table[end])+1

function print(aa::AutoAlign, alignment::Alignment, s::AbstractString)
    pos = position(aa)
    if (length(aa.widths) < pos)
        push!(aa.widths, 0)
    end
    s = normalize_string(s, stripcc=true)
    aa.widths[pos] = max(aa.widths[pos], length(s))
    push!(aa.table[end], (alignment,s))
    nothing
end

print(aa::AutoAlign, alignment::Alignment, s) = print(aa, alignment, string(s))

print(aa::AutoAlign, s) = print(aa, get_alignment(aa.alignment, position(aa)), s)

function print(aa::AutoAlign, xs...)
    for x in xs
        print(aa, x)
    end
    nothing
end

function println(aa::AutoAlign, xs...)
    print(aa, xs...)
    push!(aa.table, Vector())
    nothing
end

print(::AutoAlign, ::AutoAlign) = throw(MethodError) # suppress warning

function print(io::IO, aa::AutoAlign)
    for (i,line) in enumerate(aa.table)
        if i != 1
            println(io)
        end
        for (as,w) in zip(line,aa.widths)
            print(io, align(as[1], as[2], w))
        end
    end
    nothing
end

end # module

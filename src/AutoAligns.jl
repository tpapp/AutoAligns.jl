__precompile__()
module AutoAligns

import Base: position, print, println

export left, right, center, AutoAlign

abstract type Alignment end

struct Left <: Alignment end
const left = Left()
align_string(::Left, s::AbstractString, width::Int) = rpad(s, width)

struct Right <: Alignment end
const right = Right()
align_string(::Right, s::AbstractString, width::Int) = lpad(s, width)

struct Center <: Alignment end
const center = Center()
function align_string(::Center, s::AbstractString, width::Int)
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
    align
    table
    widths
    function AutoAlign(; align=left)
        table = Vector{Vector}()
        push!(table, Vector())
        new(align, table, Vector{Int}())
    end
end

"""
Get the position of the next item that would be printed.
"""
position(aa::AutoAlign) = length(aa.table[end])+1

_newline(aa::AutoAlign) =  (push!(aa.table, Vector()); nothing)

function _print(aa::AutoAlign, s::AbstractString, align=aa.align)
    pos = position(aa)
    if (length(aa.widths) < pos)
        push!(aa.widths, 0)
    end
    s = normalize_string(s, stripcc=true)
    aa.widths[pos] = max(aa.widths[pos], length(s))
    push!(aa.table[end], (get_alignment(align, pos),s))
    nothing
end

_print(aa::AutoAlign, x, align=aa.align) = _print(aa, string(x), align)

function print(aa::AutoAlign, xs...; align=aa.align)
    for x in xs
        _print(aa, x, align)
    end
end

function println(aa::AutoAlign, xs...; align=aa.align)
    print(aa, xs...; align=align)
    _newline(aa)
end

function print(io::IO, aa::AutoAlign)
    for (i,line) in enumerate(aa.table)
        if i != 1
            println(io)
        end
        for (as,w) in zip(line,aa.widths)
            print(io, align_string(as[1], as[2], w))
        end
    end
    nothing
end

end # module

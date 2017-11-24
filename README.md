# AutoAligns

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![Build Status](https://travis-ci.org/tpapp/AutoAligns.jl.svg?branch=master)](https://travis-ci.org/tpapp/AutoAligns.jl)
[![Coverage Status](https://coveralls.io/repos/github/tpapp/AutoAligns.jl/badge.svg?branch=master&bust=1)](https://coveralls.io/github/tpapp/AutoAligns.jl?branch=master)

This [Julia](https://julialang.org) package helps align text for printing with a monospace font, by keeping track of the maximum width of each column. It is useful for printing matrices, tables, and analogous structures, and in particular for writing methods for `Base.print`.

## Installation

This package is not yet registered on Julia's [METADATA.jl](https://github.com/JuliaLang/METADATA.jl/).
To install it, you must use the [usual procedure for unregistered packages](https://docs.julialang.org/en/stable/manual/packages/#Installing-Unregistered-Packages-1):

```julia
Pkg.clone("git://github.com/tpapp/AutoAligns.jl.git")
```

Note that the [minimum required version](https://github.com/tpapp/AutoAligns.jl/blob/master/REQUIRE) of Julia is 0.6.

## Usage

Create an `AutoAlign` object, then use `print` to save values into it, which are strings or converted to strings. The `AutoAlign` object keeps track of the current column (which you can query with `position`, but that is rarely necessary), and you can also provide a default alignment, or specify it before printing, using the methods
```{julia,eval=false}
print(aa::AutoAlign, xs...)
println(aa::AutoAlign, xs...)
```
where the latter starts a new line after saving the values. Both accept a keyword argument `align`, for specifying alternate alignent for the preceding arguments.

Alignment can be specified as follows:

1. an atom `left`, `right`, or `center`, or any other user extension which is a subtype of `Alignment`,
2. a vector of alignment specifiers: for positions outside the length of the vector, the last element is used,
3. a `Dict` of `position => alignment` pairs, where the position `:default` provides the alignment for items not in the `Dict`.

## Example

````julia
julia> using AutoAligns

julia> aa = AutoAlign(align = Dict(1 => left, :default => right));

julia> for (i, r) in zip([1, 100, 10000], ["a", "bb", "ccc"])
           print(aa, r)
           for j in 1:5
               print(aa, "  ", i+j) # padding
           end
           println(aa)
       end

julia> print(STDOUT, aa)
a        2      3      4      5      6
bb     101    102    103    104    105
ccc  10001  10002  10003  10004  10005
````

## Notes

Spaces or separators such as `|` are not treated in a special way, and therefore should be accounted for when specifying positions for alignment.

Printing an `AutoAlign` object to a stream pads the strings with spaces so as to achieve the desired alignment.

An `AutoAlign` object is **not a subtype of `IO`,** as it does not implement a `write(::AutoAlign, x::UInt8)` method. Unlike `IOBuffer`, printing does not delete the contents.

Custom alignment types can be defined as subtypes of `Alignment`, by implementing `align_string`.

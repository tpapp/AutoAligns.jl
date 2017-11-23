## example for README
using AutoAligns
aa = AutoAlign(align = Dict(1 => left, :default => right));
for (i,r) in zip([1,100,10000],["a","bb","ccc"])
    print(aa, r)
    for j in 1:5
        print(aa, "  ", i+j) # padding
    end
    println(aa)
end
print(STDOUT, aa)

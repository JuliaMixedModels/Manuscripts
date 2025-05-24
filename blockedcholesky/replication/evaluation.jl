using Chairmarks, DataFrames, InteractiveUtils, LinearAlgebra, Pkg, PRIMA
using MixedModels       # want this to be after PRIMA

versioninfo()

println(Pkg.status())
println()
println(BLAS.get_config())
println()

const dat = DataFrame(MixedModels.dataset(:insteval));
dat.service = float.(dat.service .== "Y");
const form = @formula(y ~ 1 + service + (1|s) + (1|d) + (1|dept) + (0 + service|dept));

function timeit(form=form, dat=dat)
    m = LinearMixedModel(form, dat)
    fit!(m; progress=false);
    println(m.optsum)
    println()
    # evaluate objective at the converged values from OpenBLAS with 1 thread 
    thetaOB1 = [0.27572694783915613, 0.4352917263395991, 0.04316230740526005, 0.1299749675679518];
    @show(objective(updateL!(setθ!(m, thetaOB1))))
    println()
    println(@b objective(updateL!(setθ!($m, thetaOB1))))
    MixedModels.prfit!(m; progress=false);
    println(m.optsum)
end

timeit()

using AppleAccelerate

println(BLAS.get_config())
println()

timeit()

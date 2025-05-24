using Chairmarks, DataFrames, InteractiveUtils, LinearAlgebra, Pkg, PRIMA
using MixedModels       # want this to be after PRIMA
using AppleAccelerate       
# using MKL

versioninfo()

println(Pkg.status())
println()
println(BLAS.get_config())
println()

dat = DataFrame(MixedModels.dataset(:insteval));
dat.service = float.(dat.service .== "Y");
form = @formula(y ~ 1 + service + (1|s) + (1|d) + (1|dept) + (0 + service|dept));

m1 = fit(MixedModel, form, dat; progress=false);

println(m1.optsum)
println()

# evaluate objective at the converged values from OpenBLAS with 1 thread 
thetaOB1 = [0.27572694783915613, 0.4352917263395991, 0.04316230740526005, 0.1299749675679518];
@show(objective(updateL!(setθ!(m1, thetaOB1))))
println()

println(@b objective(updateL!(setθ!($m1, $(m1.θ)))))

m1pr = MixedModels.prfit!(m1; progress=false);

println(m1pr.optsum)

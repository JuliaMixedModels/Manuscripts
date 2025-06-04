using MKL_jll
using MixedModels       # want this to be after PRIMA
import CSV

const dat = MixedModels.dataset(:insteval);
const form = @formula(y ~ 1 + service + (1|s) + (1|d) + (1|dept) + (0 + service|dept));
const m1 = LinearMixedModel(form, dat)
@assert m1.optsum.initial == ones(4)

const progress = false
pltfrmtags = Base.BinaryPlatforms.HostPlatform().tags
const arch = pltfrmtags["arch"]
const os = pltfrmtags["os"]
obj(θ::Vector{Float64}) = objective(updateL!(setθ!(m1, θ)))
BLAS = "OpenBLAS"
tbl = [(; os, arch, BLAS, initial=obj(ones(4)))]

# install accelerated BLAS
@static if Sys.isapple() && arch == "aarch64"
  using AppleAccelerate
  BLAS = "AppleAccelerate"
elseif MKL_jll.is_available()
  using MKL
  BLAS = "MKL"
end

push!(tbl, (; os, arch, BLAS, initial=obj(ones(4))))
CSV.write("../data/evaluation.csv", tbl)
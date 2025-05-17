using Pkg
Pkg.instantiate()

Pkg.add("RCall")


#| output: false
using AlgebraOfGraphics, CairoMakie, PrettyTables, Printf, SparseArrays, LinearAlgebra
using Arrow, Chairmarks, CSV, DataFrames, MixedModels
dat = DataFrame(MixedModels.dataset("insteval"))
dat.service = float.(dat.service .== "Y")       # convert to 0/1 encoding
sumry = describe(dat, :min, :max, :mean, :nunique, :eltype)

#| echo: false
#| output: asis
#| tbl-cap: Summary of the `insteval` dataset
#| label: tbl-insteval-summary
fmt_nothing = (v, i, j) -> isnothing(v) ? "-" : v
pretty_table(
  sumry,
  formatters = (ft_round(2, [4]), fmt_nothing),
  show_subheader = false, backend = Val(:latex))

#| echo: false
#| output: false
# set up the environment
using MKL_jll
hostarch = Base.BinaryPlatforms.arch(Base.BinaryPlatforms.HostPlatform())
@static if Sys.isapple() && hostarch == "aarch64"
  using AppleAccelerate
elseif MKL_jll.is_available()
  using MKL
end
# override QuartoNotebookRunner https://github.com/PumasAI/QuartoNotebookRunner.jl/issues/294
CairoMakie.activate!(; type="pdf")

form = @formula(y ~ 1 + service + (1|d) + (1|s) + (1|dept) + (0 + service|dept))
m1 = fit(MixedModel, form, dat, progress=false) # suppress display of a progress bar
print(m1)

@be fit($MixedModel, $form, $dat; progress=false)  seconds=8

@be objective(updateL!(setθ!($m1, $(m1.θ))))

show([typeof(rt) for rt in m1.reterms])

show([length(rt.levels) for rt in m1.reterms])

show([size(rt, 2) for rt in m1.reterms])

#| tbl-cap: Block Structure of the `A` matrix \label{tab:blk-descrip}
#| tbl-cap-location: top
BlockDescription(m1)

θ̂ = m1.θ
show(θ̂)

m1.λ

#| echo: false
#| label: fit-false
m2 = LinearMixedModel(form, dat);

#| echo: false
#| label: fit-reorder
m2.reterms[1:2] = m2.reterms[2:-1:1]; # swap elements 1 and 2

A, L = MixedModels.createAL(m2.reterms, m2.Xymat); # recreate A, L

copyto!(m2.A, A); # set A
copyto!(m2.L, L); # set L

#| echo: false
refit!(m2; progress = false);

#| echo: false
#| fig-cap: Sparsity pattern of the augmented matrix $\mbfA$ when the order of the random effects is not carefully chosen (left) and when the order is carefully chosen (right).
#| label: fig-a
include("scripts/makiespy.jl")
CairoMakie.activate!(; type="png")

f = Figure()
spyA(m2, f[1,1]; markersize = 5, colormap = :imola) # m2 is the slower model
spyA(m1, f[1,2]; markersize = 5, colormap = :imola) # m1 is the slower model
f

#| echo: false
#| fig-cap: Sparsity pattern of the lower triangular Cholesky factor when the order of the random effects is not carefully chosen (left) and when the order is carefully chosen (right).
#| label: fig-blk

second(x) = x[2]
reszfast = second.(size.(m1.reterms))
reszslow = second.(size.(m2.reterms))
szl, _ = size(sparseL(m1; full = true))


f = Figure(figure_padding = 60)
spyL(m2, f[1,1]; markersize = 5, colormap = :imola) # m2 is the slower model
spyL(m1, f[1,2]; markersize = 5, colormap = :imola) # m1 is the slower model
colgap!(f.layout, 50.)


x0, y0 = content(f[1,1]).scene.viewport.val.origin
xw, yw = content(f[1,1]).scene.viewport.val.widths
bracket!(
  f.scene,
  x0,  y0 + yw,
  x0 + xw * (reszslow[1] / szl), y0 + yw,
  text = string(reszslow[1])
)

bracket!(
  f.scene,
  x0 + xw * (reszslow[1] / szl),  y0 + yw,
  x0 + xw * (reszslow[1] + reszslow[2]) / szl, y0 + yw,
  text = string(reszslow[2])
)



bracket!(
  f.scene,
  x0,  y0 + yw,
  x0, y0 + yw - yw * (reszslow[1] / szl),
  text = string(reszslow[1]),
  orientation = :down,
)

bracket!(
  f.scene,
  x0,  y0 + yw - yw * (reszslow[1] / szl),
  x0, y0 + yw - yw * (reszslow[1] + reszslow[2]) / szl,
  text = string(reszslow[2]),
  orientation = :down
)

x0, y0 = content(f[1,2]).scene.viewport.val.origin
xw, yw = content(f[1,2]).scene.viewport.val.widths
bracket!(
  f.scene,
  x0,  y0 + yw,
  x0 + xw * reszfast[1] / szl, y0 + yw,
  text = string(reszfast[1])
)

bracket!(
  f.scene,
  x0 + xw * reszfast[1] / szl,  y0 + yw,
  x0 + xw * (reszfast[1] + reszfast[2]) / szl, y0 + yw,
  text = string(reszfast[2])
)

bracket!(
  f.scene,
  x0,  y0 + yw,
  x0, y0 + yw - yw * reszfast[1] / szl ,
  text = string(reszfast[1]),
  orientation = :down
)

bracket!(
  f.scene,
  x0,  y0 + yw - yw * reszfast[1] / szl,
  x0, y0 + yw - yw * (reszfast[1] + reszfast[2]) / szl,
  text = string(reszfast[2]),
  orientation = :down
)

f

#| echo: false
CairoMakie.activate!(; type="pdf");

#| echo: false
#| output: false
movies = DataFrame(Arrow.Table("./data/moviesnratngs.arrow"))
users = DataFrame(Arrow.Table("./data/usersnratngs.arrow"))

#| echo: false
#| fig-cap: "Empirical distribution plots of the number of ratings per movie and per user.  The horizontal axes are on a logarithmic scale."
#| label: fig-nrtngsecdf
#| warning: false
let
  f = Figure(; size=(800, 300))
  xscale = log10
  xminorticksvisible = true
  xminorgridvisible = true
  yminorticksvisible = true
  xminorticks = IntervalsBetween(10)
  ylabel = "Relative cumulative frequency"
  nrtngs = sort(movies.nrtngs)
  ecdfplot(
    f[1, 1],
    nrtngs;
    npoints=last(nrtngs),
    axis=(
      xlabel="Number of ratings per movie (logarithmic scale)",
      xminorgridvisible,
      xminorticks,
      xminorticksvisible,
      xscale,
      ylabel,
      yminorticksvisible,
    ),
  )
  urtngs = sort(users.nrtngs)
  ecdfplot(
    f[1, 2],
    urtngs;
    npoints=last(urtngs),
    axis=(
      xlabel="Number of ratings per user (logarithmic scale)",
      xminorgridvisible,
      xminorticks,
      xminorticksvisible,
      xscale,
      yminorticksvisible,
    ),
  )
  f
end

#| echo: false
#| output: false
sizespeed = CSV.read("./data/sizespeed.csv", DataFrame; downcast=true);

#| echo: false
#| label: fig-nratingsbycutoff
#| fig-cap: "Number of ratings (left) and movies (right) in reduced table by movie cutoff and by user cutoff"
#| warning: false

function siformat(x)
    if x >= 1_000_000
        val = x / 1_000_000
        suffix = "M"
    elseif x >= 1_000
        val = x / 1_000
        suffix = "K"
    else
        val = x
        suffix = ""
    end

    return string(@sprintf("%g", val), suffix)
end

draw(
  data(sizespeed) *
  mapping(
    :mc => "Minimum number of ratings per movie",
    [:nratings => "Total number of ratings", :nmvie => "Number of movies in table"],
    col = dims(1) => renamer(["Ratings", "Movies"]),
    color = :uc => renamer([20 => "≥20 ratings", 40 => "≥40 ratings", 80 => "≥80 ratings"])  => "per user",
  ) * visual(ScatterLines);
  legend = (; position = :bottom, titleposition = :left),
  axis = (; ytickformat = values -> [siformat(value) for value in values]),
  figure=(; size=(800, 350))
)

#| echo: false
#| fig-cap: Memory footprint of the model representation by minimum number of ratings per user and per movie.
#| label: fig-memoryfootprint
#| warning: false
draw(
  data(sizespeed) *
  mapping(
    :mc => "Minimum number of ratings per movie",
    :modelsz => "Size of model object (GiB)",
    color = :uc => renamer([20 => "≥20 ratings", 40 => "≥40 ratings", 80 => "≥80 ratings"])  => "per user",) *
    visual(ScatterLines);
    legend = (; position = :bottom, titleposition = :left),
)

#| echo: false
#| fig-cap: Proportion of memory footprint of the model in L[2,2] versus the overall model size (GiB).
#| label: fig-l22prop
#| warning: false
draw(
  data(transform!(sizespeed, [:L22sz, :modelsz] => ((x, y) -> x ./ y) => :L22prop)) *
  mapping(
    :modelsz => "Size of model object (GiB)",
    :L22prop => "Proportion of memory footprint in L[2,2]",
    color = :uc => renamer([20 => "≥20 ratings", 40 => "≥40 ratings", 80 => "≥80 ratings"])  => "per user",) *
    visual(ScatterLines);
    legend = (; position = :bottom, titleposition = :left),
)

#| echo: false
#| fig-cap: "Evaluation time for the objective (s) versus size of the [2,2] block of L (GiB)"
#| label: fig-evtimevsl22
#| warning: false
draw(
  data(sizespeed) *
  mapping(
    :L22sz => "Size of [2,2] block of L (GiB)",
    :evtime => "Time for one evaluation of objective (s)",
    color = :uc => renamer([20 => "≥20 ratings", 40 => "≥40 ratings", 80 => "≥80 ratings"])  => "per user",) *
    visual(ScatterLines);
    legend = (; position = :bottom, titleposition = :left),
)

mreml = fit(
  MixedModel,
  @formula(y ~ 1 + service + (1 | d) + (1 | s) + (1 | dept) + (0 + service | dept)),
  dat,
  REML = true,
  progress=false
)
print(mreml)

#| eval: false
m2 = fit(
  MixedModel,
  @formula(y ~ 1 + service + (1 | d) + (1 | s) + (1 | dept) + (0 + service | dept)),
  dat,
  progress=false    # suppress the display of a progress bar
);

#| eval: false
m2.reterms[1:2] = m2.reterms[2:-1:1]; # swap elements 1 and 2

A, L = MixedModels.createAL(m2.reterms, m2.Xymat); # recreate A, L

copyto!(m2.A, A); # set A
copyto!(m2.L, L); # set L

@be refit!($m2; progress = false) seconds = 100 # very slow

@be refit!($m1, progress = false) seconds = 8

print(m2)

#| echo: false
#| output: asis
#| tbl-cap: Summary of results for the `ml-32m` data modeling run speeds
#| label: tbl-sizespeed
sizespeed = CSV.read("./data/sizespeed.csv", DataFrame; downcast=true);
rename!(sizespeed,
        :mc => "movie cutoff",
        :uc => "user cutoff",
        :nratings => "ratings",
        :nusers => "users",
        :nmvie => "movies",
        :modelsz => "model (GiB)",
        :L22sz => "L[2,2] (GiB)",
        :fittime => "time (s)",
        :nv => "n eval",
        :evtime => "time per eval (s)")
pretty_table(sizespeed; formatters = ft_round(2, [6, 7, 9, 10]), backend = Val(:markdown), show_subheader = false)



BLAS.get_config()

using Pkg; Pkg.status()

using RCall

R"""
library(lme4, quietly = TRUE)
library(glmmTMB)
library(microbenchmark)
dat <- InstEval
dat$service <- as.numeric(dat$service) - 1  # convert to a 0/1 numeric vector
ctrl <- lmerControl(calc.derivs = FALSE)
form <- y ~ 1 + service + (1 | s) + (1 | d) + (1 | dept) + (0 + service | dept)
mlmer <- lmer(form, dat, REML = FALSE, control = ctrl)
print(summary(mlmer, correlation = FALSE))
tmbmod <- glmmTMB(form, dat)
print(summary(tmbmod))
microbenchmark(
  lmer = lmer(form, dat, REML = FALSE, control = ctrl),
  glmmTMB = glmmTMB(form, dat), times = 6
) |> print()
# R and package versions
print(R.version.string)
print(packageVersion("lme4"))
print(packageVersion("glmmTMB"))
"""

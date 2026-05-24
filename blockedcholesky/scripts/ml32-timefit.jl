using Arrow, DataFrames, MixedModels, PRIMA

function timefit(
    mc::Integer,
    uc::Integer,
    ratings::AbstractDataFrame;
    initial_step::Vector{<:AbstractFloat} = [0.5, 0.5],
    ftol_rel::AbstractFloat = 1.0e-10,
    backend::Symbol = :nlopt,
    optimizer::Symbol = :LN_BOBYQA,
    )
    df = ratings[(ratings.mnrtngs .≥ mc) .& (ratings.unrtngs .≥ uc), :]
    nratings = size(df, 1)
    nusers = length(unique(df.userId))
    nmvie = length(unique(df.movieId))
    model = LinearMixedModel(@formula(rating ~ 1 + (1|userId) + (1|movieId)), df)
    model.optsum.initial_step = initial_step
    model.optsum.ftol_rel = ftol_rel
    model.optsum.ftol_abs = 1.0e-6
    model.optsum.backend = backend
    model.optsum.optimizer = optimizer
    testpar = [inv(sqrt(2.)), inv(sqrt(3.))]    # non-integer parameter value for evaluation time check
    objective(updateL!(setθ!(model, testpar)))  # evaluation to force compilation of methods
    modelsz = Base.summarysize(model) / (2^30)  # size in GiB
    L22sz = Base.summarysize(model.L[3]) / (2^30)
    evtime = @elapsed objective(updateL!(setθ!(model, testpar)))  # time for one evaluation of objective
    @info (; mc, uc, nratings, nusers, nmvie, modelsz, L22sz, evtime)
    fittime = @elapsed fit!(model; progress=isinteractive())
    nv = length(model.optsum.fitlog)
    return model, (; mc, uc, nratings, nusers, nmvie, modelsz, L22sz, nv, fittime, evtime)
end


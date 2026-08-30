using Arrow, CSV, DataFrames, Downloads, MixedModels, ZipFile
const ML_32M_URL = "https://files.grouplens.org/datasets/movielens/ml-32m.zip"

const ML_32M_LOCAL = joinpath("data", "ml-32m.zip")

function extract_csv(zipfile, fname; kwargs...)
    file = only(filter(f -> endswith(f.name, fname), zipfile.files))
    return CSV.read(file, DataFrame; delim=',', header=1, kwargs...)
end

function load_zipfile()
    if !isfile(ML_32M_LOCAL)
        @info "Downloading data"
        Downloads.download(ML_32M_URL, ML_32M_LOCAL)
    end
    zipfile = ZipFile.Reader(ML_32M_LOCAL)
    ratings = extract_csv(
        zipfile,
        "ratings.csv";
        drop=[4],
        types=[Int32, Int32, Float32, Int32],
        pool=[true, true, true, false],
    )
    close(zipfile)
    movies = combine(groupby(ratings, :movieId), nrow => :mnrtngs)  # number of ratings per movie
    movies.mnrtngs = Int32.(movies.mnrtngs)
    users = combine(groupby(ratings, :userId), nrow => :unrtngs)
    users.unrtngs = Int32.(users.unrtngs)
    disallowmissing!(leftjoin!(leftjoin!(ratings, movies; on=:movieId), users; on=:userId))
    Arrow.write("data/ratings.arrow", ratings; compress=:zstd)
    Arrow.write("data/moviesnratngs.arrow", movies; compress=:zstd)
    Arrow.write("data/usersnratngs.arrow", users; compress=:zstd)
    return ratings, movies, users
end

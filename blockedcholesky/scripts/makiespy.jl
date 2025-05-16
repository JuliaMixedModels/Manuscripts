# helper functions
ncols(X::T) where {T} = size(X)[2]
second(x) = x[2]

# function to generate lower triangular half of A matrix
function augmat(m1, matsym::Symbol, print=false)
    totcols = sum(ncols.(m1.reterms)) + ncols(m1.Xymat)
    nrws = vcat(ncols.(m1.reterms), ncols(m1.Xymat))
    nblkrows = length(m1.reterms) + 1
    szblocks = vcat(ncols.(m1.reterms), ncols(m1.Xymat))
    zerosz = totcols .- cumsum(szblocks)

    if (length(szblocks) != nblkrows)
        error("[augmat]: Num rows doesnt match length of block sizes array")
    end

    rws = Vector{SparseMatrixCSC}()
    for blk in 1:nblkrows
        stblk = binomial(blk, 2)+1
        endblk = stblk + (blk - 1)
        push!(rws,
              hcat(hcat(getfield(m1, matsym)[stblk:endblk]...),
                   zeros(nrws[blk], zerosz[blk])))
    end
    M = vcat(rws...)
    if (print)
        spy(M)
    end
    return vcat(rws...)
end

function spyA(m::LinearMixedModel, gp; kwargs...)
    A = augmat(m, :A, false)
    A = A + A' - Diagonal(A)
    Lflip = A[end:-1:1, :]'
    n, _ = size(Lflip)
    ax = Axis(gp; aspect=1)

    spy!(gp, Lflip; kwargs...)

    rszs = second.(size.(m.reterms))

    xtt = cumsum(rszs)[1:(end - 1)]
    ytt = n .- xtt

    ax.xticks = (xtt, string.(xtt))
    ax.yticks = (ytt, string.(xtt))
    ax.xaxisposition = :top

    hlines!(gp, ytt; color=:black)
    return vlines!(gp, xtt; color=:black)
end

function spyL(m::LinearMixedModel, gp; kwargs...)
    Lflip = sparseL(m; full=true)[end:-1:1, :]'
    n, _ = size(Lflip)
    ax = Axis(gp; aspect=1)

    spy!(gp, Lflip; kwargs...)

    rszs = second.(size.(m.reterms))

    xtt = cumsum(rszs)[1:(end - 1)]
    ytt = n .- xtt

    ax.xticks = (xtt, string.(xtt))
    ax.yticks = (ytt, string.(xtt))
    ax.xaxisposition = :top
    hidedecorations!(ax; ticklabels=true)

    hlines!(gp, ytt; color=:black)
    return vlines!(gp, xtt; color=:black)
end

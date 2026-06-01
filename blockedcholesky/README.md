# Replication Materials for "Mixed-model Log-likelihood Evaluation Via a Blocked Cholesky Factorization"


## Steps

- Install the current Julia release version according to the instructions at https://julialang.org/downloads
- Install (or update) [`quarto`](https://quarto.org/) version 1.9.0 or greater
- Install `jupyter-cache` using the instructions from the quarto Julia docs [here](https://quarto.org/docs/computations/julia.html#jupyter-cache).
- Install the `JuliaMono` font, see instructions at: https://juliamono.netlify.app
- Install the [`JDS extensions`](https://github.com/wenjie2wang/jds.qmd) for [`quarto`](https://quarto.org)
- Install the required `Julia` dependencies by running:
    ```bash
    julia --project=@. -e "import Pkg; Pkg.instantiate()"
    ```
- Generate the JDL formatted preview using:
    ```bash
    make render
    ```
- If you get errors due to caching, try using the `--no-cache` option for quarto:
    ```bash
    quarto render BlockedCholeskyMM.qmd --no-cache --to jds-pdf    # for JDS version render
    ```
- To create a Julia script from the Quarto file (`BlockedCholeskyMM.qmd`) convert the .qmd file to a Jupyter notebook and apply `jupyter nbconvert` to create a script.
    ```bash
    quarto convert BlockedCholeskyMM.qmd
    jupyter nbconvert --no-prompt --to script BlockedCholeskyMM.ipynb
    mv BlockedCholeskyMM.txt BlockedCholeskyMM.jl
    ```
- Alternatively, `Quarto mode` for editors such as [VSCode](https://code.visualstudio.com) or [Positron](https://positron.posit.co) provide the ability to interactively evaluate code chunks from a Quarto document.

- Comparison fits in R using the `lme4` and `glmmTMB` packages are shown in `Environment.pdf` generated from `Environment.qmd`

- Because the ml-32m dataset cannot be redistributed, reproduction of the results in Table 4, require a separate script, `scripts/ml32-download.jl` to download the data, create the ratings table, and save it in the [Arrow](https://arrow.apache.org) format. The evaluation of the models is performed by `ml32-timefit.jl` **but** be aware that fitting very large models like this requires a computer with a large amount of memory (64 GiB is recommended) and can take a long time.  It took roughly 18 hours for all the model fits on a cloud compute instance with the characteristics shown in `config.txt`.

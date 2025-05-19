# Replication Materials for "Mixed-model Log-likelihood Evaluation Via a Blocked Cholesky Factorization"


## Steps

- Install `jupyter-cache` using the instructions from the quarto Julia docs [here](https://quarto.org/docs/computations/julia.html#jupyter-cache).
- Install the `JuliaMono` font, see instructions at: https://juliamono.netlify.app
- Install required `Julia` dependencies by running:
   ```bash
    $ julia --project=@. -e "import Pkg; Pkg.instantiate()"
   ```
- Generate the JSS formatted preview using:
    ```bash
     $ make render
    ```
- Generate the arXiv formatted version using:
    ```bash
    $ make render-arxiv
    ```
    **Note:** this command re-runs the `R` benchmark script which can take a long time.
    **Note:** For the arxiv version, you need to have `cbfonts-fd` and `cbfonts` packages installed in your latex distribution
- If you get errors due to caching, try using the `--no-cache` option for quarto:
    ```bash
    quarto render BlockedCholeskyMM.qmd --no-cache                      # for JSS version render
    quarto render BlockedCholeskyMM.qmd --no-cache --to arxiv-pdf+arxiv # for arxiv version

    ```

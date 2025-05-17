# Replication Materials for "Mixed-model Log-likelihood Evaluation Via a Blocked Cholesky Factorization"


## Steps

- Install `jupyter-cache` using the instructions from the quarto Julia docs [here](https://quarto.org/docs/computations/julia.html#jupyter-cache).
- Install required `Julia` dependencies by running:
   ```bash
    $ julia --project=@. -e "import Pkg; Pkg.instantiate()"
   ```
- Generate the JSS formatted preview using:
    ```bash
     $ make preview
     ... lots of output ...
    
     # hit Ctrl + C to stop the preview
    ```
- Generate the arXiv formatted version using:
    ```bash
    $ make render-arxiv
    ```
    **Note:** this command re-runs the `R` benchmark script which can take a long time.
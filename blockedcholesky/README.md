# Replication Materials for "Mixed-model Log-likelihood Evaluation Via a Blocked Cholesky Factorization"


## Steps

- Install required dependencies by running:
   ```bash
    $ julia --project=@. -e "import Pkg; Pkg.instantiate(pwd())"
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
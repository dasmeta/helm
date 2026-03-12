# The Dasmeta kubernetes helm charts

## To be able to install the charts please add dasmeta repo as follows:
```sh
helm repo add dasmeta https://dasmeta.github.io/helm
```

### The available charts and the docs how to configure them can be found in [./charts](./charts) folder. Chart-specific docs and example values live in each chart's README and in [examples/<chart-name>/](./examples/) (e.g. [examples/base/](./examples/base/)).


## For developers
1. enable local git pre-commit hooks by running the following command in your terminal
```bash
git config --global core.hooksPath ./githooks
```
2. For spec-driven chart work: use feature branches `001-<feature-name>`, then run `/speckit.specify`, `/speckit.plan`, and `/speckit.tasks`; specs live under `specs/` and workflow config under `.specify/`.

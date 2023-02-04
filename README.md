# Github action to build an H5P content type library (BETA)
Builds an H5P content type library incl. checks.

## Features
- Checks the validity of translation files
  - Valid JSON file structure
  - Translation matching semantics.json (via [H5P CLI](https://github.com/h5p/h5p-cli))
- Lints if a `lint` script is defined in `package.json`
- Builds if a `build` script is defined in `package.json`

## Important note
The H5P CLI tool is currently being rewritten completely. To prevent breaking
changes, the version that's used is pinned.

## Example
Inside your repository, make sure there's a directory called
`.github/workflows`. Inside that repository, create a file with a name along the
lines of `reuse-h5p-build.yml` that should contain something like this:

```
name: Build H5P content type

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

jobs:
  build:
    uses: otacke/github-action-h5p-build/.github/workflows/h5p-build.yml@v1
```

Please refer to the
[github action documentation](https://docs.github.com/en/actions) for details.

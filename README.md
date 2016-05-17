# The ScGrog Package

## Introduction

Self-calibrating GROG is a technique for calculating unit kx and ky stepping GRAPPA operators (usually called Gx and Gy) which can be used in the regular GROG method.

The [original GROG method](http://www.ncbi.nlm.nih.gov/pubmed/17969027) was first published by Seiberlich et. al. in 2007 and the [self-calibrating theory](http://onlinelibrary.wiley.com/doi/10.1002/mrm.21565/abstract) for radial data was worked out by the same group in 2008.

This package contains several key components which are explained in the following sections.

### NPM

This package uses the node package manager to manage its version control and dependencies. To use this package simply:

1. Install Node: https://nodejs.org/en/

2. Run `npm install sc-grog` at a unix-like terminal.

This will automatically download the files for this package (and the packages it depends on) into a `node_modules` folder. If you add this folder to your MATLAB path the package `ScGrog` will be available.

It is crucial to note the difference in naming conventions between MATLAB and NPM. The npm package name is `sc-grog` and the MATLAB package name is `+ScGrog`. If you are new to MATLAB packages please learn more about them here: http://www.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html.


### Tests

To make sure this software works as expected in the present environment, tests have been provided and can be run by executing `ScGrog.test`. These tests provide a very basic data-in data-out testing and it's these example data files that take up the bulk of the size of this repository.

Since all test data is stored in +tests/private, the files in this folder should not be version controlled. You need to tell your local `git` to not track changes in them via `git update-index --assume-unchanged` as described here: http://stackoverflow.com/questions/12288212/git-update-index-assume-unchanged-on-directory.

If you want to contribute to this project please keep tests in mind and do not commit any new data without telling git to "assume-unchanged" to avoid bloating the .git file.

### Docs

In the `docs/` directory a markdown file is provided explaining how to use the function this package provides.

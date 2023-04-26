
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![CRAN
status](https://www.r-pkg.org/badges/version/stdsim)](https://cran.r-project.org/package=stdsim)
[![DOI](https://zenodo.org/badge/204009603.svg)](https://zenodo.org/badge/latestdoi/204009603)

# stdsim

The goal of stdsim is to simulate sample and standard measurements to
allow optimisation of the Empirical Transfer Function, the calibration
from the machine scale of standards to an absolute reference frame.

## Installation

You can install the released version of stdsim from
[GitHub](https://github.com/japhir) with:

``` r
devtools::install_github("japhir/stdsim")
```

## Example

This shows how to run one simulation with some input parameters:

``` r
options(genplot=TRUE, verbose=TRUE)
library(stdsim)
#> Warning in find.package(package, lib.loc, quiet = TRUE, verbose = verbose): package 'stdsim' found more than once, using the first from
#>   "/tmp/Rtmpu3Tjsb/temp_libpatha2cde633e2ebf/stdsim",
#>   "/home/japhir/R/x86_64-pc-linux-gnu-library/stdsim"
#> Warning in find.package(package, fp.lib.loc, quiet = TRUE): package 'stdsim' found more than once, using the first from
#>   "/tmp/Rtmpu3Tjsb/temp_libpatha2cde633e2ebf/stdsim",
#>   "/home/japhir/R/x86_64-pc-linux-gnu-library/stdsim"
#> now dyn.load("/usr/lib/R/library/grid/libs/grid.so") ...
#> now dyn.load("/home/japhir/R/x86_64-pc-linux-gnu-library/glue/libs/glue.so") ...
#> now dyn.load("/home/japhir/R/x86_64-pc-linux-gnu-library/colorspace/libs/colorspace.so") ...
#> now dyn.load("/home/japhir/R/x86_64-pc-linux-gnu-library/vctrs/libs/vctrs.so") ...
#> now dyn.load("/home/japhir/R/x86_64-pc-linux-gnu-library/magrittr/libs/magrittr.so") ...
#> now dyn.load("/home/japhir/R/x86_64-pc-linux-gnu-library/fansi/libs/fansi.so") ...
#> now dyn.load("/home/japhir/R/x86_64-pc-linux-gnu-library/utf8/libs/utf8.so") ...
#> now dyn.load("/home/japhir/R/x86_64-pc-linux-gnu-library/tibble/libs/tibble.so") ...
#> now dyn.load("/home/japhir/R/x86_64-pc-linux-gnu-library/dplyr/libs/dplyr.so") ...
#> now dyn.load("/home/japhir/R/x86_64-pc-linux-gnu-library/purrr/libs/purrr.so") ...
sim_stds(stdfreqs=c(1, 1, 9, 0, 0), stdn=50, smpn=30, stdev=25, smpt=5, out="pl")
#> starting simulation
#> simulating sample measurements
#> simulating standard measurements
#> 2 standard measurements not simulated due to roundoff.
#> calculating empirical transfer function (ETF)
#> applying ETF to sample
#> calculating summary statistics of raw values
#> calculating 95% confidence intervals of regression at computed raw value in raw space
#> calculating 95% confidence intervals of sample in expected space
#> creating plots
#> now dyn.load("/home/japhir/R/x86_64-pc-linux-gnu-library/Rcpp/libs/Rcpp.so") ...
#> now dyn.load("/home/japhir/R/x86_64-pc-linux-gnu-library/ggrepel/libs/ggrepel.so") ...
#> `geom_smooth()` using formula = 'y ~ x'
#> now dyn.load("/usr/lib/R/library/splines/libs/splines.so") ...
#> 
#> now dyn.load("/home/japhir/R/x86_64-pc-linux-gnu-library/lattice/libs/lattice.so") ...
#> 
#> now dyn.load("/usr/lib/R/library/nlme/libs/nlme.so") ...
#> 
#> now dyn.load("/home/japhir/R/x86_64-pc-linux-gnu-library/Matrix/libs/Matrix.so") ...
#> 
#> now dyn.load("/usr/lib/R/library/mgcv/libs/mgcv.so") ...
#> Warning: The following aesthetics were dropped during statistical transformation: fill
#> ℹ This can happen when ggplot fails to infer the correct grouping structure in
#>   the data.
#> ℹ Did you forget to specify a `group` aesthetic or to convert a numerical
#>   variable into a factor?
#> now dyn.load("/home/japhir/R/x86_64-pc-linux-gnu-library/farver/libs/farver.so") ...
```

<img src="man/figures/README-example-1.png" width="100%" />

    #> `geom_smooth()` using formula = 'y ~ x'
    #> Warning: The following aesthetics were dropped during statistical transformation: fill
    #> ℹ This can happen when ggplot fails to infer the correct grouping structure in
    #>   the data.
    #> ℹ Did you forget to specify a `group` aesthetic or to convert a numerical
    #>   variable into a factor?

<img src="man/figures/README-example-2.png" width="100%" />

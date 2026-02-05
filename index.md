# powergrid ![](reference/figures/powergrid_color_floor.png)

The powergrid package is intended to allow users to easily evaluate a
function across a grid of input parameters. The utilities in the package
are aimed at performing analyses of *power and sample size*, allowing
for easy search of minimum n (or min/max of any other parameter) to
achieve a minimal level of power (or a maximum of any value). Also,
plotting functions are included that present the dependency of n and
power in relation to further parameters.

The package (version 0.5.0) is available from
[CRAN](https://CRAN.R-project.org/package=powergrid) and may be
installed through your favorite mirror.

Note that the package is developed further here on SCTO’s github. If you
want to use a development version (newer than the CRAN version), make
sure you explicitly refer to the current release when loading the
package in your code, using argument `tag` to `install_github`.

``` r
devtools::install_github("SwissClinicalTrialOrganisation/powergrid",
                         tag = 'v0.5.0', # replace with development version, or
                                         # omit to install the current main
                                         # branch.
                         build_vignette = TRUE)
library(powergrid)
```

Powergrid is a package mainly developed by [Gilles
Dutilh](https://www.gillesdutilh.com/statistics/), partly funded by a
[Statistical programming
grant](https://www.sctoplatforms.ch/en/scto-platforms/statistics-methodology-5.html)
from the SCTO. Valuable contributions have been made by [Richard
Allen](https://dkf.unibas.ch/de/team-data-analysis-statistik/) of the
statistics team at DKF basel.

## Package highlights

The strengths of the `powergrid` package are:

- any number of input parameters to search along may be included easily
- any number of output parameters are handled intuitively
- whether performing simulation-based or closed-form power-analyses, the
  powergrid utilities behave the same way
- the objective may be to achieve at least a certain value (in the case
  of power), but also at most a certain value (as in the case of
  expected credence intervals)
- the parameter that is optimized to achieve the objective may be
  something you want to be small (e.g., n), or allow to be large (e.g.,
  the maximal permissible SD).

## Example usage

Define a grid of parameters to evaluate a function across:

``` r
sse_pars <- list( # a simple list
  n = seq(from = 10, to = 60, by = 5), # sample size
  sd = seq(from = 0.1, to = 1, by = 0.1) # standard deviation
)
```

Define a function to evaluate the parameters across the grid. The
function should take the parameters as input and return a single value
(e.g., power, sample size, etc.). For example, we can use the
`power.t.test` function from the `stats` package to calculate power for
a t-test:

``` r
PowFun <- function(n, sd){
  ptt = power.t.test(n = n/2,
                     delta = .6,
                     sd = sd,
                     sig.level = 0.05)
  return(ptt$power)
}
```

Evaluate the function at each grid node:

``` r
power <- PowerGrid(pars = sse_pars, fun = PowFun)
```

Display the results:

``` r
PowerPlot(power)
```

![](reference/figures/readmeplot-1.png)

See the vignette for more details on how to use the package and its
functions.

Please don’t hesitate making an issue above or contributing through a
pull request. You may also contact Gilles by
[email](mailto:info@gillesdutilh.com).

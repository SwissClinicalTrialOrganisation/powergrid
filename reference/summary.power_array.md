# Summary of power_grid object.

Offers a short summary of the power_array object, summarizing the range
of observed values and the grid evaluated across. \##' See PowerGrid for
details

## Usage

``` r
# S3 method for class 'power_array'
summary(object, ...)
```

## Arguments

- object:

  array of class power_grid

- ...:

  passed on to `cat`

## Value

nothing

## See also

[`PowerGrid`](https://swissclinicaltrialorganisation.github.io/powergrid/reference/PowerGrid.md)

## Author

Gilles Dutilh

## Examples

``` r
## Define grid of assumptions to study:
sse_pars = list(
  n = seq(from = 10, to = 50, by = 20),         # sample size
  delta = seq(from = 0.5, to = 1.5, by = 0.5), # effect size
  sd = seq(.1, 1, .3))                        # standard deviation

## Define function that calculates power based on these assumptions:
PowFun <- function(n, delta, sd){
  ptt = power.t.test(n = n/2, delta = delta, sd = sd,
                     sig.level = 0.05)
  return(ptt$power)
}

## Evaluate at each combination of assumptions: 
powarr = PowerGrid(pars = sse_pars, fun = PowFun, n_iter = NA)
summary(powarr)
#>  Object of class: power_array
#> 
#>  Range of values: [0.1, 1] 
#>  Evaluated at:
#>       n 10, 30, 50
#>   delta 0.5, 1, 1.5
#>      sd 0.1, 0.4, 0.7, 1
```

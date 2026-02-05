# indexing with \[ \] for class `power_array` \[ \]: R:%20

Method for indexing \[\] of objects of class power_array. The method
makes sure that the resulting array is of class power_array and keeps
and updates the object's attributes. These attributes are needed for
various functions in the powergrid package to work well. \##' The
indexing functions as normal indexing, but note that drop is FALSE by
default, so that the resulting array has the same dimensions as the
original array. The number of levels at each dimension may be reduced,
however. \##'

## Usage

``` r
# S3 method for class 'power_array'
x[..., drop = TRUE]
```

## Arguments

- x:

  object

- ...:

  index

- drop:

  drop

## Value

An array of class `power_grid`

## See also

[`PowerGrid`](https://swissclinicaltrialorganisation.github.io/powergrid/reference/PowerGrid.md)
[`ArraySlicer`](https://swissclinicaltrialorganisation.github.io/powergrid/reference/ArraySlicer.md)
for a different method of reducing the dimensions of an array of class
power_array.

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
powarr[2, 1, ] # gives the same as
#> [1] 1.0000000 0.9104815 0.4716852 0.2619313
#> Array of class `power_array` created using
#> PowerGrid.
#>   One resulting dimension (dimension's name was dropped by indexing).
#> 
powarr['30', '0.5', ]
#> [1] 1.0000000 0.9104815 0.4716852 0.2619313
#> Array of class `power_array` created using
#> PowerGrid.
#>   One resulting dimension (dimension's name was dropped by indexing).
#> 
```

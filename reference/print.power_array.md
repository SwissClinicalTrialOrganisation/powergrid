# print

Method for printing objects of class power_array. \##' Prints a
power_array as a default array with a short summary about its contents.

## Usage

``` r
# S3 method for class 'power_array'
print(x, ...)
```

## Arguments

- x:

  object of class power_array

- ...:

  passed on to `cat`

## Value

Nothing

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
print(powarr)
#> , , sd = 0.1
#> 
#>     delta
#> n          0.5         1       1.5
#>   10 0.9999993 1.0000000 1.0000000
#>   30 1.0000000 1.0000000 1.0000000
#>   50 1.0000000 1.0000000 1.0000000
#> 
#> , , sd = 0.4
#> 
#>     delta
#> n          0.5         1       1.5
#>   10 0.4129428 0.9315752 0.9992276
#>   30 0.9104815 0.9999982 1.0000000
#>   50 0.9910928 1.0000000 1.0000000
#> 
#> , , sd = 0.7
#> 
#>     delta
#> n          0.5         1       1.5
#>   10 0.1681223 0.5103278 0.8420422
#>   30 0.4716852 0.9652339 0.9998914
#>   50 0.6965931 0.9985937 1.0000000
#> 
#> , , sd = 1
#> 
#>     delta
#> n          0.5         1       1.5
#>   10 0.1038399 0.2859276 0.5493642
#>   30 0.2619313 0.7529210 0.9774319
#>   50 0.4099896 0.9337076 0.9993912
#> 
#> Array of class `power_array` created using
#> PowerGrid.
#>  Resulting dimensions:
#>  n, delta, sd.
#> 
```

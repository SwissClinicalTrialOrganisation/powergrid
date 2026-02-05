# Transform power_array into power_df

Transforms an object of class `power_array` to a data.frame, where
values are stored in column x, and all other dimensions are columns.
Some may find this "more tidy" to work with.

The class of the data.frame becomes \`c("power_df", "data.frame"),
enabling generics for data.frame. Note that the class "power_df" has
currently no use but is included for future compatibility.

## Usage

``` r
PowerDF(x)
```

## Arguments

- x:

  Object of class `power_array`

## Value

An object of with classes c("power_df", "data.frame"), with the same
attributes as `x`, aside from array-native attributes (dimnames, dim),
plus the data.frame attributes `names` and `row_names`.

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
print(PowerDF(powarr))
#>     n delta  sd         x
#> 1  10   0.5 0.1 0.9999993
#> 2  30   0.5 0.1 1.0000000
#> 3  50   0.5 0.1 1.0000000
#> 4  10     1 0.1 1.0000000
#> 5  30     1 0.1 1.0000000
#> 6  50     1 0.1 1.0000000
#> 7  10   1.5 0.1 1.0000000
#> 8  30   1.5 0.1 1.0000000
#> 9  50   1.5 0.1 1.0000000
#> 10 10   0.5 0.4 0.4129428
#> 11 30   0.5 0.4 0.9104815
#> 12 50   0.5 0.4 0.9910928
#> 13 10     1 0.4 0.9315752
#> 14 30     1 0.4 0.9999982
#> 15 50     1 0.4 1.0000000
#> 16 10   1.5 0.4 0.9992276
#> 17 30   1.5 0.4 1.0000000
#> 18 50   1.5 0.4 1.0000000
#> 19 10   0.5 0.7 0.1681223
#> 20 30   0.5 0.7 0.4716852
#> 21 50   0.5 0.7 0.6965931
#> 22 10     1 0.7 0.5103278
#> 23 30     1 0.7 0.9652339
#> 24 50     1 0.7 0.9985937
#> 25 10   1.5 0.7 0.8420422
#> 26 30   1.5 0.7 0.9998914
#> 27 50   1.5 0.7 1.0000000
#> 28 10   0.5   1 0.1038399
#> 29 30   0.5   1 0.2619313
#> 30 50   0.5   1 0.4099896
#> 31 10     1   1 0.2859276
#> 32 30     1   1 0.7529210
#> 33 50     1   1 0.9337076
#> 34 10   1.5   1 0.5493642
#> 35 30   1.5   1 0.9774319
#> 36 50   1.5   1 0.9993912
```

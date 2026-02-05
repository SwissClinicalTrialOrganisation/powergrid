# Cut slice from array (typically of class `power_array`)

Cut out a slice from an array. The resulting slice may be single- or
multidimensional. The function is intended for arrays of class
"power_array", and makes sure that the resulting array is of class
power_array and keeps and, where needed, updates the object's
attributes. These attributes are needed for various functions in the
powergrid package to work well.

## Usage

``` r
ArraySlicer(x, slicer = NULL)
```

## Arguments

- x:

  An array, in most common use cases an array of class `power_array`,
  but may be any array with named dimensions.

- slicer:

  A list whose named elements define at which dimension (the list
  element names), at which values (the list element values) a slice is
  taken from `power_array`. Default NULL returns the unchanged array.

## Value

An array with reduced dimensions as given by `slicer`. Note that,
relative to a standard array, some additional attributes are passed to
be used in the functions in package `powergrid`

## Details

Internally, indexing (\[) is used, but the implementation in ArraySlicer
is very flexible allowing for any number of dimensions in any order in
the `slicer` argument. The resulting slice is always an array, also if
only one dimension is left. `dimnames` are kept intact.

## See also

[`PowerGrid`](https://swissclinicaltrialorganisation.github.io/powergrid/reference/PowerGrid.md),
`[.power_array` for reducing the dimensions of an array of class
`power_array` using \[-indexing.

## Author

Gilles Dutilh

## Examples

``` r
sse_pars = list(
  n = seq(from = 20, to = 60, by = 5),
  delta = seq(from = 0.5, to = 1.5, by = 0.2),
  sd = seq(.1, .9, .2),
  alpha = c(.05, .025, .1)) # a 4-dimensional grid
PowFun <- function(n, delta, sd, alpha){
  ptt = power.t.test(n = n/2, delta = delta, sd = sd,
                     sig.level = alpha)
  return(ptt$power)
}
power_array = PowerGrid(pars = sse_pars, fun = PowFun, n_iter = NA)
## cut out a 2-dimensional plane:
ArraySlicer(power_array,
            slicer = list(alpha = .1, sd = .9))
#>     delta
#> n          0.5       0.7       0.9       1.1       1.3       1.5
#>   20 0.3266194 0.5113619 0.6935575 0.8372357 0.9278669 0.9736115
#>   25 0.3832766 0.5955822 0.7824609 0.9064024 0.9683517 0.9916914
#>   30 0.4363362 0.6675901 0.8477025 0.9473643 0.9865455 0.9974895
#>   35 0.4859190 0.7284933 0.8946573 0.9709510 0.9944270 0.9992664
#>   40 0.5321084 0.7795046 0.9279025 0.9842242 0.9977416 0.9997915
#>   45 0.5749929 0.8218632 0.9511155 0.9915513 0.9991018 0.9999421
#>   50 0.6146775 0.8567685 0.9671303 0.9955305 0.9996486 0.9999843
#>   55 0.6512851 0.8853366 0.9780638 0.9976612 0.9998645 0.9999958
#>   60 0.6849538 0.9085756 0.9854597 0.9987880 0.9999484 0.9999989
#> Array of class `power_array` created using
#> PowerGrid.
#>  Resulting dimensions:
#>  n, delta.
#> 
## Note that above, the dimension levels are called as numeric values, so the
## following works as well:
ArraySlicer(power_array,
            slicer = list(alpha = 0.1, sd = 0.9))
#>     delta
#> n          0.5       0.7       0.9       1.1       1.3       1.5
#>   20 0.3266194 0.5113619 0.6935575 0.8372357 0.9278669 0.9736115
#>   25 0.3832766 0.5955822 0.7824609 0.9064024 0.9683517 0.9916914
#>   30 0.4363362 0.6675901 0.8477025 0.9473643 0.9865455 0.9974895
#>   35 0.4859190 0.7284933 0.8946573 0.9709510 0.9944270 0.9992664
#>   40 0.5321084 0.7795046 0.9279025 0.9842242 0.9977416 0.9997915
#>   45 0.5749929 0.8218632 0.9511155 0.9915513 0.9991018 0.9999421
#>   50 0.6146775 0.8567685 0.9671303 0.9955305 0.9996486 0.9999843
#>   55 0.6512851 0.8853366 0.9780638 0.9976612 0.9998645 0.9999958
#>   60 0.6849538 0.9085756 0.9854597 0.9987880 0.9999484 0.9999989
#> Array of class `power_array` created using
#> PowerGrid.
#>  Resulting dimensions:
#>  n, delta.
#> 
## They can be called by their actual character values as well:
ArraySlicer(power_array,
            slicer = list(alpha = '0.1', sd = '0.9'))
#>     delta
#> n          0.5       0.7       0.9       1.1       1.3       1.5
#>   20 0.3266194 0.5113619 0.6935575 0.8372357 0.9278669 0.9736115
#>   25 0.3832766 0.5955822 0.7824609 0.9064024 0.9683517 0.9916914
#>   30 0.4363362 0.6675901 0.8477025 0.9473643 0.9865455 0.9974895
#>   35 0.4859190 0.7284933 0.8946573 0.9709510 0.9944270 0.9992664
#>   40 0.5321084 0.7795046 0.9279025 0.9842242 0.9977416 0.9997915
#>   45 0.5749929 0.8218632 0.9511155 0.9915513 0.9991018 0.9999421
#>   50 0.6146775 0.8567685 0.9671303 0.9955305 0.9996486 0.9999843
#>   55 0.6512851 0.8853366 0.9780638 0.9976612 0.9998645 0.9999958
#>   60 0.6849538 0.9085756 0.9854597 0.9987880 0.9999484 0.9999989
#> Array of class `power_array` created using
#> PowerGrid.
#>  Resulting dimensions:
#>  n, delta.
#> 
## (compare with dimnames(power_array))
## the following does not work:
if (FALSE) { # \dontrun{
ArraySlicer(power_array,
            slicer = list(alpha = '.1', sd = '.9'))
} # }
##
## Cut out multiple levels from one dimension
ArraySlicer(power_array,
            slicer = list(alpha = .1, sd = c(.9, .7)))
#> , , sd = 0.9
#> 
#>     delta
#> n          0.5       0.7       0.9       1.1       1.3       1.5
#>   20 0.3266194 0.5113619 0.6935575 0.8372357 0.9278669 0.9736115
#>   25 0.3832766 0.5955822 0.7824609 0.9064024 0.9683517 0.9916914
#>   30 0.4363362 0.6675901 0.8477025 0.9473643 0.9865455 0.9974895
#>   35 0.4859190 0.7284933 0.8946573 0.9709510 0.9944270 0.9992664
#>   40 0.5321084 0.7795046 0.9279025 0.9842242 0.9977416 0.9997915
#>   45 0.5749929 0.8218632 0.9511155 0.9915513 0.9991018 0.9999421
#>   50 0.6146775 0.8567685 0.9671303 0.9955305 0.9996486 0.9999843
#>   55 0.6512851 0.8853366 0.9780638 0.9976612 0.9998645 0.9999958
#>   60 0.6849538 0.9085756 0.9854597 0.9987880 0.9999484 0.9999989
#> 
#> , , sd = 0.7
#> 
#>     delta
#> n          0.5       0.7       0.9       1.1       1.3       1.5
#>   20 0.4570025 0.6935575 0.8685265 0.9584072 0.9904886 0.9984479
#>   25 0.5350629 0.7824609 0.9295853 0.9847885 0.9978551 0.9998053
#>   30 0.6039964 0.8477025 0.9632142 0.9946389 0.9995396 0.9999770
#>   35 0.6643634 0.8946573 0.9811787 0.9981668 0.9999051 0.9999974
#>   40 0.7168148 0.9279025 0.9905394 0.9993888 0.9999811 0.9999997
#>   45 0.7620649 0.9511155 0.9953169 0.9998006 0.9999963 1.0000000
#>   50 0.8008528 0.9671303 0.9977127 0.9999361 0.9999993 1.0000000
#>   55 0.8339099 0.9780638 0.9988960 0.9999799 0.9999999 1.0000000
#>   60 0.8619365 0.9854597 0.9994728 0.9999937 1.0000000 1.0000000
#> 
#> Array of class `power_array` created using
#> PowerGrid.
#>  Resulting dimensions:
#>  n, delta, sd.
#> 
```

# Summary of object that has individual iterations saved.

Summarizes objects of class `power_array` that have individual
iterations saved.

## Usage

``` r
SummarizeIterations(x, summary_function, ...)
```

## Arguments

- x:

  Object of class `power_array`

- summary_function:

  function to apply across iterations

- ...:

  Further arguments passed to 'summary_function'

## Value

An object of class `power_array`, with attributes `summarized = TRUE`.

## See also

[`PowerGrid`](https://swissclinicaltrialorganisation.github.io/powergrid/reference/PowerGrid.md)

## Author

Gilles Dutilh

## Examples

``` r
## iterative sse example
sse_pars = list(
  n = seq(from = 10, to = 60, by = 5),
  delta = seq(from = 0.5, to = 1.5, by = 0.2),
  sd = seq(.5, 1.5, .2))

## Define a function that results in TRUE or FALSE for a successful or
## non-successful (5% significant) simulated trial:
PowFun <- function(n, delta, sd){
  x1 = rnorm(n = n/2, sd = sd)
  x2 = rnorm(n = n/2, mean = delta, sd = sd)
  t.test(x1, x2)$p.value < .05
}

n_iter = 20
powarr = PowerGrid(pars = sse_pars, fun = PowFun,
                        n_iter = n_iter, summarize = FALSE)

dimnames(powarr)
#> $n
#>  [1] "10" "15" "20" "25" "30" "35" "40" "45" "50" "55" "60"
#> 
#> $delta
#> [1] "0.5" "0.7" "0.9" "1.1" "1.3" "1.5"
#> 
#> $sd
#> [1] "0.5" "0.7" "0.9" "1.1" "1.3" "1.5"
#> 
#> $iter
#>  [1] "1"  "2"  "3"  "4"  "5"  "6"  "7"  "8"  "9"  "10" "11" "12" "13" "14" "15"
#> [16] "16" "17" "18" "19" "20"
#> 
summary(powarr) # indicates that iterations were not
#>  Object of class: power_array
#> Containing output of 20 individual iterations.
#>  Range of values: [0, 1] 
#>  Evaluated at:
#>       n 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60
#>   delta 0.5, 0.7, 0.9, 1.1, 1.3, 1.5
#>      sd 0.5, 0.7, 0.9, 1.1, 1.3, 1.5
## now summarize
powarr_summarized = SummarizeIterations(powarr, summary_function = mean)
dimnames(powarr_summarized)
#> $n
#>  [1] "10" "15" "20" "25" "30" "35" "40" "45" "50" "55" "60"
#> 
#> $delta
#> [1] "0.5" "0.7" "0.9" "1.1" "1.3" "1.5"
#> 
#> $sd
#> [1] "0.5" "0.7" "0.9" "1.1" "1.3" "1.5"
#> 
summary(powarr_summarized) # indicates that iterations are now summarized
#>  Object of class: power_array
#> Containing summary over 20 iterations,
#> summarized by function `mean` (for function
#> definition, see attribute `summary_function`).
#>  Range of values: [0, 1] 
#>  Evaluated at:
#>       n 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60
#>   delta 0.5, 0.7, 0.9, 1.1, 1.3, 1.5
#>      sd 0.5, 0.7, 0.9, 1.1, 1.3, 1.5
```

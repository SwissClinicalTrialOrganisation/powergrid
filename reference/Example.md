# Find combination of parameters required for achieving a desired power (or other objective).

Find combination of parameters yielding desired power (or any other
target value) in an object of class "power_array".

## Usage

``` r
Example(
  x,
  example = NULL,
  target_value = NULL,
  target_at_least = TRUE,
  find_lowest = TRUE,
  method = "step",
  summary_function = mean
)
```

## Arguments

- x:

  Object of class `power_array`

- example:

  List with named elements representing the constellation of parameter
  values for which the example should be found. The names of this list
  should match the dimension names of `x`, their values should be exact
  values available at these dimensions. See example for an illustration.

- target_value:

  Which value (of typically power) should be achieved at the example.

- target_at_least:

  Logical. Set to TRUE if you aim to achieve a minimum value (e.g., a
  power must be *at least* 90%), or FALSE if you want to allow a maximum
  value (e.g., the width of the expected CI may be *at most* a certain
  value).

- find_lowest:

  Logical, indicating whether the example should be found that minimizes
  a parameter (typically: minimal required n) to achieve the
  `target_value` or maximizes this assumption (e.g., maximal allowed
  SD).

- method:

  Character string, indicating how the location of the example is found,
  passed on internally to `FindTarget`. Either "step": walking in steps
  along the parameter of interest or "lm": Interpolating assuming a
  linear relation between the parameter of interest and (qnorm(x) +
  qnorm(1

  - 0.05)) ^ 2. This method "lm" is inspired on the implementation in
    the sse package by Thomas Fabbro.

- summary_function:

  When x' attribute `summarized` is FALSE, x is summarized across
  iterations using this function before searching the example.

## Value

Example returns a list containing:

- "requested_example": the parameter combination at which the power (or
  whatever the values represent) was searched to achieve level
  `target_value` (typically the minimal power, e.g., .9), searching
  along parameter `required name` (typically n).

- "objective": was `required_name` searched to find the "min" or "max"
  of x?

- "target_value": which value should the power (or any other value)
  have?

- "required_name": the parameter searched along to find the minimum (or
  maximized if slot `searched` = 'max') to achieve objective. (typically
  n)

- "required_value": the minimum (or maximum if `searched` = "max") for
  parameter `required_name` (which is typically n)

- "searched": was the "min" or "max" for `required_name` searched?

- "target_at_least": Is the target_value a minimum (TRUE, as typical for
  power) or a maximum (FALSE, e.g., an expected uncertainty level)?

## Details

In the most typical use case, and this is also the default, `Example`
searches the *minimal* n where the power is *at least* equal to the
value given by argument `target`. The function is, however, designed
much more generically. The explanation below may be less helpful than
trying the examples, but for completeness:

Argument `example` slices out a vector from object `x`, representing the
values at the parameter combination given in example, thus, along the
remaining parameter. Then, `Example` searches along this vector for the
*minimal* parameter value where the value of the vector is *at least*
equal to `target`. Thus, if the sliced out vector contains values of
"power" along the parameter "effect size", it searches the minimal
effect size at which the target power is achieved.

Two complications are made to allow for complete flexibility:

1.  In the above description, *minimal* can be changed to *maximal* by
    setting argument `find_lowest` to FALSE. This is useful in the
    situation where one, e.g., searches for the highest standard
    deviation at which it is still possible to find a desirable power.

2.  In the above description, *at least* can be changed to *at most* by
    setting `target_at_least` to FALSE. This allows to search, for
    example, for the minimal sample size where the expected confidence
    interval is smaller than a certain desired width.

Example searches for the minimum or maximum on one parameters (say, the
minimum n) given *one single constellation* of further parameters.
However, you may want to study how, say, the required n (or any other
value) depends on the value of further parameters. The functions
PowerPlot and GridPlot offer plotting functionalities to graphically
illustrate such dependencies. If you want to find "Examples" as a
function of parameter settings and work with these, you can use the
workhorse behind 'Example', PowerPlot and Gridplot,
[`FindTarget`](https://swissclinicaltrialorganisation.github.io/powergrid/reference/FindTarget.md)

## See also

[`PowerGrid`](https://swissclinicaltrialorganisation.github.io/powergrid/reference/PowerGrid.md),
[`FindTarget`](https://swissclinicaltrialorganisation.github.io/powergrid/reference/FindTarget.md),
[`PowerPlot`](https://swissclinicaltrialorganisation.github.io/powergrid/reference/PowerPlot.md),
[`GridPlot`](https://swissclinicaltrialorganisation.github.io/powergrid/reference/GridPlot.md)

## Author

Gilles Dutilh

## Examples

``` r
## ============================================
## Typical use case: find lowest n for a certain target power
## ============================================
sse_pars = list(
  n = seq(from = 10, to = 60, by = 2),
  delta = seq(from = 0.5, to = 1.5, by = 0.1), ## effect size
  sd = seq(.1, .9, .2)) ## Standard deviation
PowFun <- function(n, delta, sd){
  ptt = power.t.test(n = n/2, delta = delta, sd = sd,
                     sig.level = 0.05)
  return(ptt$power)
}
power_array = PowerGrid(pars = sse_pars, fun = PowFun, n_iter = NA)
##'
ex_out = Example(power_array,
                 example = list(delta = .7, sd = .7),
                 target_value = .9)
ex_out #
#> ================================================
#> To achieve the target value of at most 0.9 assuming
#> delta = 0.7
#> sd = 0.7,
#> the minimal required n = 46
#> ------------------------------------------------
#> Description: Method "step" was used to find the
#> lowest n in the searched grid that yields a
#> target_value (typically power) of at least 0.9.
#> ================================================

## ============================================
## Illustration argument `find_lowest`
## ============================================
##
## In this example, we search for the *highest sd* for which the power is at
## least .9.
ex_out = Example(power_array,
                 example = list(n = 40, delta = .7),
                 target_value = .9, find_lowest = FALSE)
ex_out # note how the printed result indicates it searched for a maximal
#> ================================================
#> To achieve the target value of at most 0.9 assuming
#> n = 40
#> delta = 0.7,
#> maximal permissible sd = 0.5
#> ------------------------------------------------
#> Description: Method "step" was used to find the
#> highest sd in the searched grid that yields a
#> target_value (typically power) of at least 0.9.
#> ================================================
                                        # permissible sd.

## ============================================
## Illustration argument `target_at_least`
## ============================================
##
## In the example below, we search for the lowest n where the expected CI-width
## is not larger than .88.
PowFun <- function(n, delta, sd){
  x1 = rnorm(n = n/2, sd = sd)
  x2 = rnorm(n = n/2, mean = delta, sd = sd)
  CI_width = diff(t.test(x1, x2)$conf.int) # CI95 is saved
}
sse_pars = list(
  n = seq(from = 10, to = 60, by = 5),
  delta = seq(from = 0.5, to = 1.5, by = 0.2),
  sd = seq(.5, 1.5, .2))
## we iterate, and take the average across iterations to get expected CI-width:
n_iter = 20
set.seed(1)
power_array = PowerGrid(pars = sse_pars, fun = PowFun, n_iter = n_iter)
summary(power_array)
#>  Object of class: power_array
#> Containing summary over 20 iterations,
#> summarized by function `summary_function` (for
#> function definition, see attribute
#> `summary_function`).
#>  Range of values: [0.5, 4.66] 
#>  Evaluated at:
#>       n 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60
#>   delta 0.5, 0.7, 0.9, 1.1, 1.3, 1.5
#>      sd 0.5, 0.7, 0.9, 1.1, 1.3, 1.5
## Now, find lowest n for which the average CI width is *smaller than .88*.
ex_out = Example(power_array,
                 example = list(delta = .7, sd = .7),
                 target_value = .88,
                 find_lowest = TRUE, # we search the *lowest* n
                 target_at_least = FALSE # for a *maximal* mean CI width
                 )
ex_out # note how the printed result indicates the target CI is a maximum.
#> ================================================
#> To achieve the target value of at most 0.88 assuming
#> delta = 0.7
#> sd = 0.7,
#> the minimal required n = 40
#> ------------------------------------------------
#> Description: Method "step" was used to find the
#> lowest n in the searched grid that yields a
#> target_value (typically power) of at most 0.88.
#> ================================================

## ============================================
## When both `find_lowest` and `target_at_least` are FALSE
## ============================================
##
## In this example, we search for the *highest sd* for which the average CI
## width is still *smaller than or equal to .88*.
ex_out = Example(power_array,
                 example = list(delta = .7, n = 60),
                 target_value = .88,
                 find_lowest = FALSE, # we search the *highest* sd
                 target_at_least = FALSE # for a *maximal* mean CI width
                 )

ex_out # note how the printed result indicates that the *maximal permissible SD*
#> ================================================
#> To achieve the target value of at most 0.88 assuming
#> delta = 0.7
#> n = 60,
#> maximal permissible sd = 0.7
#> ------------------------------------------------
#> Description: Method "step" was used to find the
#> highest sd in the searched grid that yields a
#> target_value (typically power) of at most 0.88.
#> ================================================
       # was found for a CI of *at most .88*.
```

#' Some of these are a bit undecided as to whether they are tests for FindTarget
#' or for Example().

sse_pars = list(
  n = seq(from = 10, to = 60, by = 5),
  delta = seq(from = 0.5, to = 1.5, by = 0.1),
  sd = seq(.5, 1.5, .1))
closed_fun <- function(n, delta, sd){
  power.t.test(n=n, delta = delta, sd=sd)$power
}
closed_power_array <- PowerGrid(pars = sse_pars, fun = closed_fun,
                                summarize = FALSE)

## ===============================================================

test_that(
  "Error about defaults for method='lm' correctly thrown from Example()",
  {expect_error(Example(closed_power_array,
        example = list(delta=0.6, sd= 1.0),
        target = 0.5, minimal_target = FALSE,
        method="lm"))})

## =============================================================================

#' Suppressing warnings may be bad practice, but this is not the goal of this test.
suppressWarnings(
result1 <- Example(closed_power_array,
                   example = list(delta=0.9, sd= 1.0),
                   target = 0.8, method="lm")
)
comparison1 <- ceiling(power.t.test(delta = 0.9, sd=1.0, power=0.8)$n)
test_that(
  "Gives correct required n under defaults (lm)",
  {expect_equal(result1$required_value, comparison1,
                ignore_attr=TRUE)}
)


test_that(
  "Warns the user about rounding (lm)",
  {expect_warning(Example(closed_power_array, example = list(n=35, sd= 1.0),
                        target = 0.8, method="lm"))}
)

test_that(
  "Gives correct required value under defaults (step)",
  {expect_equal(Example(closed_power_array,
                        example = list(delta=0.9, sd= 1.0),
                        target = 0.8)$required_value, 25)}
)


## =============================================================================
#' Conversion of the target is maybe a bit extreme.
test_that(
  "Can handle small variations in numeric specification",
  {expect_equal(Example(closed_power_array,
                        example = list(delta=.90, sd= 1.00),
                        target = "0.8000")$required_value, 25)}
)
## =============================================================================
#' Testing printed output of Example. print_comparison is generated from the
#' same summary function. So more of a test for future issues.

Example_test <-
  Example(closed_power_array,
        example = list(delta=0.6, sd= 1.0),
        target = 0.5)

print_comparison <-
  c("================================================",
    "To achieve the target of at least 0.5 assuming",
    "delta = 0.6",
    "sd = 1,",
    "the minimal required n = 25",
    "------------------------------------------------",
    "Description: Method \"step\" was used to find the",
    "lowest n in the searched grid that yields a",
    "target (typically power) of at least 0.5.",
     "================================================")
test_that(
  "Print method of output is correct format",
  {expect_equal(capture.output(Example_test), print_comparison,ignore_attr = TRUE)}
)

## =============================================================================




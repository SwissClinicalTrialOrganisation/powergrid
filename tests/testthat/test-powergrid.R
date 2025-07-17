
#' TODO: naming of test files should be consistent (either camelcaps or lowercase)

## ===============================================================
#' TODO: I think this should be in test-SummariseSims no?

## Test warning summarizing summarized object
PowFun <- function(n, delta, sd){
  x1 = rnorm(n = n/2, sd = sd)
  x2 = rnorm(n = n/2, mean = delta, sd = sd)
  t.test(x1, x2)$p.value < .05
}
sse_pars = list(
  n = seq(from = 10, to = 60, by = 20),
  delta = seq(from = 0.5, to = 1.5, by = 0.5),
  sd = seq(.5, 1.5, .5))
##
n_iter = 20
power_array = PowerGrid(pars = sse_pars, fun = PowFun,
                        n_iter = n_iter, summarize = TRUE)
test_that(
  "trying to summarize an object that is already summarized throws a warning",
  {expect_error(
    SummarizeSims(power_array, summary_function = mean)
  )}
)

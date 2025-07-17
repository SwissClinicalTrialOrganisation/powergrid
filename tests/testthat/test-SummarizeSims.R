#' TODO: PowerGrid should internally call SummarizeSims to summarize

## ===============================================================

TestFun <- function(prop_min, threshold){
  prop <-runif(n = 1, min = prop_min, max = 1)
  prop - threshold
}
test_pars = list(
  prop_min = seq(from = 0, to = 1, by = 0.05),
  threshold = seq(from = 0, to = 1, by = 0.05))

n_iter = 100
power_array = PowerGrid(pars = test_pars, fun = TestFun,
                        n_iter = n_iter, summarize = FALSE)
summarized_power_array <- SummarizeSims(power_array, summary_function = min)
test_result <-
  summarized_power_array[lower.tri(summarized_power_array, diag = TRUE)]
test_that(
  "Test correct assignment of values to output, and user defined function",
  {expect_true(all(test_result>=0))}
)
## ===============================================================

#' Test a comparison for a typical use case
sse_pars = list(
  n = seq(from = 10, to = 60, by = 20),
  delta = seq(from = 0.5, to = 1.5, by = 0.5),
  sd = seq(.5, 1.5, .5))

iter_fun <- function(n, delta, sd){
  x1 = rnorm(n = n, sd = sd)
  x2 = rnorm(n = n, mean = delta, sd = sd)
  t.test(x1, x2, var.equal=TRUE)$p.value < .05
}

closed_fun <- function(n, delta, sd){
  power.t.test(n=n, delta = delta, sd=sd,)$power
}

#' Tested with the following seeds (but seed not set).
# set.seed(c(123, 726)[2])
power_array = PowerGrid(pars = sse_pars, fun = iter_fun,
                        n_iter = 1000, summarize = FALSE)
summarized_power_array <- SummarizeSims(power_array,summary_function = mean)

closed_power_array <- PowerGrid(pars = sse_pars, fun = closed_fun,
                                summarize = FALSE)
test_that(
  "SummariseSims gives an accurate summary of power in 2 sample t test",
  {expect_equal(summarized_power_array, closed_power_array, ignore_attr=TRUE,
               tolerance = 0.03)}
)
## ===============================================================

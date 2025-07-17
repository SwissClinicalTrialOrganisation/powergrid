slicer_pars = list(
  A = seq(from = 100, 700,100),
  B = seq(from = 10, 80, 10),
  C = seq(1, 9, 1))
slicer_fun <- function(A, B, C){
  A+B+C
}
slicer_power_array <- PowerGrid(pars = slicer_pars, fun = slicer_fun,
                                summarize = FALSE)

## =============================================================================

test_that(
  "Appropriate error thrown when a bad dimension name used",
  {expect_error(ArraySlicer(slicer_power_array,
                        slicer = list(badname=0.9, B= 20)))}
)

test_that(
  "Appropriate error thrown when a bad value used",
  {expect_error(ArraySlicer(slicer_power_array,
                        slicer = list(A=NA, C= 3)))}
)


## =============================================================================
result1 <- ArraySlicer(slicer_power_array, slicer=NULL)
test_that(
  "Empty list as slicer, leaves array contents unchanged",
  {expect_equal(result1, slicer_power_array, ignore_attr=TRUE)}
)

result2 <- ArraySlicer(slicer_power_array, slicer=list(A=100, B=10, C=1))
test_that(
  "Fully specified values gives single value",
  {expect_equal(result2, 111, ignore_attr=TRUE)}
)

#' Stripping the class to get a good comparison is a challenge
result3 <- ArraySlicer(slicer_power_array, slicer=list(A=c(400,100), B=40)) |>
  as.array() |>
  unclass()
comparison3 <-
  .mapply(slicer_fun, expand.grid(A=c(400, 100), B= 40, C=seq(1,9,1)), MoreArgs = NULL) |>
  sapply(I, simplify = "array") |>
  array(dim=c(2,9))
test_that(
  "Output has elements in order specified by slicer",
  {expect_equal(result3, comparison3, ignore_attr=TRUE)}
)

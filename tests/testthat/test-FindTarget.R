
#' Note that FindTarget needs a vector, with names
#' TODO: I still find both the descriptions and help unintuitive

## ===============================================================

#' Tests are very simple.

slice <- setNames(seq(0.09,0.89, 0.1), nm=seq(0.1,0.9, 0.1)*10)

result1 <- FindTarget(power_slice =slice, target=0.5)
test_that(
  "FindTarget (step) identifies correct value, under defaults",
  {expect_equal(result1, 6)}
)

result2 <- FindTarget(power_slice =slice, target=0.5,
                                    minimal_target = FALSE)
test_that(
  "FindTarget (step) identifies correct value, target is a maximum",
  {expect_equal(result2, 1)}
)

result3 <- FindTarget(power_slice =slice, target=0.5,
                                find_min = FALSE)
test_that(
  "FindTarget (step) identifies correct value, minimal parameter value searched",
  {expect_equal(result3, 9)}
)

result4 <- FindTarget(power_slice =slice, target=0.5,
                                        minimal_target = FALSE, find_min = FALSE)
test_that(
  "FindTarget (step) identifies correct value, target is a maximum & minimal parameter value searched ",
  {expect_equal(result4, 5)}
)
rm(slice, result1, result2, result3, result4)
## ===============================================================

#' The values of minimal_target and find_min are ignored if method
#' equals "lm", thus tests are failed.

set.seed(123)
slice <- setNames(seq(0.09,0.89, 0.1), nm=seq(0.1,0.9, 0.1)*10)
slice <- slice + rnorm(n=length(slice), sd=0.1)

suppressWarnings(
  result1 <- FindTarget(power_slice =slice, target=0.5, method = "lm")
)
test_that(
  "FindTarget (lm) identifies correct value, under defaults",
  {expect_equal(result1, 5, ignore_attr=TRUE)}
)

test_that(
  "FindTarget (lm) throws error if minimal target is FALSE",
  {expect_error(FindTarget(power_slice =slice, target=0.5, method = "lm",
                           minimal_target = FALSE))}
)

test_that(
  "FindTarget (lm) identifies correct value, minimal parameter value searched",
  {expect_error(FindTarget(power_slice =slice, target=0.5, method = "lm",
                           find_min = FALSE))}
)
rm(slice, result1)

## ===============================================================

#' Test for the artificial case where names are a string that
#' and only some values can convert to numeric

# badname_slice <- setNames(seq(0.09,0.89, 0.1), nm=LETTERS[1:9])
# names(badname_slice)[6] <- "6"
#
# test_that(
#   "If the vector names are not numeric throw error",
#   {expect_error(FindTarget(badname_slice, target=0.5))}
# )



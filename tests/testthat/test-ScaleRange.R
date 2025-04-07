

x <- runif(100)
scaled <- ScaleRange(x, 10, 100)

test_that("ScaleRange minimum", {
  expect_equal(min(scaled), 10)
})
test_that("ScaleRange maximum", {
  expect_equal(max(scaled), 100)
})
test_that("ScaleRange length", {
  expect_equal(length(scaled), 100)
})
test_that("ScaleRange same order", {
  expect_true(all(order(scaled) == order(x)))
})

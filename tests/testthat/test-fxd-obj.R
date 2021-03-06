context("fxd-obj")

test_that("fxd-obj", {
  fxd <- fxd("doc", "label")
  expect_true(is_fxd(fxd))
  expect_equal(fxd_task(fxd), "doc")
  expect_equal(fxd_subclass(fxd), "label")
  expect_silent(fxd <- fxd("doc", NULL))
  expect_equal(fxd_subclass(fxd), NULL)
  fxd <- fxd("doc", "label")
  fxd2 <- structure(fxd, class = c("other_class", class(fxd)))
  expect_equal(fxd_task(fxd), "doc")
  expect_equal(fxd_subclass(fxd), "label")
  expect_equal(fxd_subclass(fxd("infer", "fxGeom_class")), "fxGeom_class")
})

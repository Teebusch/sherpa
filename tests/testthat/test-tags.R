test_that("attribute helper works at top level of tag", {
  tag_simple <- s$p(x_text("foo"))

  expect_s3_class(tag_simple, "shiny.tag")
  expect_equal(tag_simple$name, "p")
  expect_equal(tag_simple$attribs[["x-text"]], "foo")
  expect_length(tag_simple$children, 0)
})

test_that("Multiple sherpa attributes are spliced correctly", {
  tag_multi <- s$div(x_data("{ foo: bar }"), x_cloak())

  expect_true("x-data" %in% names(tag_multi$attribs))
  expect_true("x-cloak" %in% names(tag_multi$attribs))
})

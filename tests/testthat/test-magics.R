test_that("s_persist converts correctly within Shiny tag", {
  x <- s_persist(1)
  tag <- tags$div(`x` = x)
  rendered_html <- as.character(tag)

  expect_equal(rendered_html, '<div x="$persist(1)"></div>')
})

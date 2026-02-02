#' Convert R objects to JavaScript-ready strings
#'
#' Internal utility to ensure R types (logical, list, numeric)
#' translate correctly to Alpine.js expressions.
#'
#' @param x The value to convert.
#' @keywords internal
to_json <- function(x) {
  if (is.null(x)) {
    return("null")
  }

  jsonlite::toJSON(
    x,
    auto_unbox = TRUE, # ensures list(x = 1) becomes {x: 1} not {x: [1]}
    json_verbatim = TRUE, # don't escape objects marked as JSON/JS,
    null = "null",
    na = "null"
  )
}

#' Create a Sherpa UI from an HTML Template
#'
#' @param path Path to the .html file
#' @param ... Additional variables to pass to the template (accessible via `{{ var }}`)
#' @inheritParams use_alpine
#'
#' @seealso [shiny::htmlTemplate()]
#' @export
html_template <- function(path, stores = NULL, plugins = NULL, ...) {
  assert_sherpa_template(path)

  sherpa_deps <- use_alpine(stores = stores, plugins = plugins)

  shiny::htmlTemplate(
    filename = path,
    sherpa_deps = sherpa_deps,
    ...
  )
}


#' Sanity checks for Sherpa HTML Template
#'
#' Ensures `{{ headContent() }}` and `x-data` are present.
#' This ensures the template works correctly with Sherpa and Shiny
#'
#' @return The original path if valid, otherwise aborts.
#' @keywords internal
assert_sherpa_template <- function(path) {
  content <- readLines(path, warn = FALSE)
  content_flat <- paste(content, collapse = " ")

  if (!any(grepl("{{ headContent() }}", content, fixed = TRUE))) {
    cli::cli_abort(c(
      "x" = "Missing {.code {{ headContent() }}} in {.file {path}}.",
      "i" = "This is required to inject Shiny dependencies.",
      "*" = "Please add it inside your {.code <head>} tag."
    ))
  }

  if (!any(grepl("{{ sherpa_deps }}", content, fixed = TRUE))) {
    cli::cli_warn(c(
      "!" = "Missing {.code {{ sherpa_deps }}} in template {.path {path}}",
      "i" = "This is required to inject Alpine.js dependencies and initialise the stores.",
      "*" = "Please add it inside your {.code <head>} tag."
    ))
  }

  if (!any(grepl("x-data", content_flat, fixed = TRUE))) {
    cli::cli_abort(c(
      "x" = "No {.code x-data} attribute found in {.file {path}}.",
      "i" = "Alpine.js cannot initialize without a root {.code x-data} attribute.",
      "*" = "Add {.code x-data} to your {.code <body>} or a wrapper {.code <div>}."
    ))
  }

  if (any(grepl("<body[^>]*x-data", content_flat, ignore.case = TRUE))) {
    cli::cli_warn(c(
      "!" = "Detected {.code x-data} on the {.code <body>} tag.",
      "i" = "This can cause Alpine.js to lose state during an HMR soft-refresh.",
      "*" = "Strategy: Move {.code x-data} to a wrapper {.code <div>} inside the body."
    ))
  }

  return(path)
}


#' Activate Hot Module Reloading for a HTML-Template
#'
#' Run within your server function to register a a watcher for a HTML-Template.
#' Usually the same template that is supplie to the ui via [html_template()]
#'
#' @param path Path to the HTML template to monitor.
#' @param interval How often to check for changes in seconds.
#' @param session The Shiny session object.
#' @export
watch <- function(
  path,
  interval = 0.3,
  session = shiny::getDefaultReactiveDomain()
) {
  rlang::check_installed("later", "sherpa's HMR relies on `later` to work.")

  if (is.null(session)) {
    cli::cli_abort(
      "{.code watch()} must be used within a shiny session."
    )
  }

  if (!file.exists(path)) {
    cli::cli_abort("HMR Error: File {.file {path}} not found.")
  }

  last_mtime <- file.info(path)$mtime

  watch_loop <- function() {
    if (session$isClosed()) {
      return()
    }

    current_mtime <- file.info(path)$mtime

    if (!is.na(current_mtime) && current_mtime > last_mtime) {
      last_mtime <<- current_mtime

      tryCatch(
        {
          new_content <- htmltools::htmlTemplate(path, sherpa_deps = "") |>
            htmltools::renderDocument()
          session$sendCustomMessage("sherpa-hmr", list(html = new_content))

          cli::cli_alert_success(
            "HMR: UI swapped from {.file {path}} at {format(Sys.time(), '%H:%M:%S')}"
          )
        },
        error = function(e) {
          cli::cli_alert_danger("HMR: Failed to read {.file {path}}")
        }
      )
    }

    later::later(watch_loop, interval)
  }

  watch_loop()
}

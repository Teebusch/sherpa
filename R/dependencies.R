#' Activate Alpine.js and plugins in Shiny app
#'
#' Add this anywhere in your UI. Shiny will take care of hoisting it into your HTML page's `<head>`.
#'
#' @param plugins Character vector with Alpine plugin names (e.g. c("persist", "mask", "intersect")).
#' @param stores Character vector of names of stores that will be used. Must be initialized here.
#'
#' @return A `htmltools::tagList` with the dependencies as [htmltools::htmlDependency].
#' @export
#'
#' @examples
#' \dontrun{
#' ui <- fluidPage(
#'   use_alpine(plugins = c("mask", "persist")),
#'   div(x_data("{ open: false }"), ...)
#' )
#' }
use_alpine <- function(plugins = NULL, stores = NULL) {
  alpine_plugin_deps <- lapply(plugins, get_alpine_plugin_dep)
  set_active_plugins(plugins)

  htmltools::tagList(
    !!!alpine_plugin_deps, # plugins must be loaded before core
    get_alpine_core_dep(),
    get_sherpa_js_dep(),
    create_register_stores_script(stores)
  )
}


#' pre-registers stores to avoid "undefined" errors
#' @noRd
create_register_stores_script <- function(stores) {
  if (is.null(stores)) {
    return(NULL)
  }
  registry <- paste0(
    sprintf("Alpine.store('%s', {test: 123});", stores),
    collapse = " "
  )

  tags$head(
    tags$script(htmltools::HTML(
      sprintf(
        "document.addEventListener('alpine:init', () => { %s })",
        registry
      )
    ))
  )
}


get_alpine_core_dep <- function() {
  base_url <- sprintf(
    "%s/alpinejs@%s/dist/",
    .sherpa_globals$alpine_cdn_base,
    .sherpa_globals$alpine_version
  )

  htmltools::htmlDependency(
    name = "alpine-core",
    version = "0.0.1",
    src = c(href = base_url),
    script = list(src = "cdn.min.js", defer = NA)
  )
}


get_alpine_plugin_dep <- function(plugin_name) {
  # TODO: Map plugin names to specific paths if needed,
  # otherwise assume standard naming convention
  # e.g. @alpinejs/persist

  pkg_name <- paste0("@alpinejs/", plugin_name)
  base_url <- sprintf(
    "%s/%s@%s/dist/",
    .sherpa_globals$alpine_cdn_base,
    pkg_name,
    .sherpa_globals$alpine_version
  )

  htmltools::htmlDependency(
    name = paste0("alpine-", plugin_name),
    version = "0.0.1",
    src = c(href = base_url),
    script = list(src = "cdn.min.js", defer = NA)
  )
}


get_sherpa_js_dep <- function() {
  htmltools::htmlDependency(
    name = "sherpa",
    version = "0.0.1",
    src = c(file = system.file("js", package = "sherpa")),
    script = "sherpa.js"
  )
}


#' Register active plugins
#' @keywords internal
set_active_plugins <- function(plugins) {
  .sherpa_globals$active_plugins <- plugins
}


#' Assert that a plugin is loaded
#' @param plugin Character(1). The name of the required Alpine plugin
#' @keywords internal
assert_plugin_active <- function(plugin) {
  active <- .sherpa_globals$active_plugins

  if (!plugin %in% active) {
    # extract name of the calling function as string
    caller_name <- rlang::call_name(sys.call(-1))

    cli::cli_warn(c(
      "!" = "Helper {.fn {caller_name}} requires the {.val {plugin}} plugin.",
      "i" = "Please add it to your UI: {.code use_alpine(plugins = '{plugin}')}"
    ))
  }
}

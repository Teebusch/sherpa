#' Activate Alpine.js and plugins in Shiny app
#'
#' Add this anywhere in your UI. Shiny will take care of hoisting it into your HTML page's `<head>`.
#'
#' @param plugins Character vector with Alpine plugin names (e.g. c("persist", "mask", "intersect")).
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
  alpine_plugin_deps <- purrr::map(plugins, get_alpine_plugin_dep)

  htmltools::tagList(
    !!!alpine_plugin_deps, # plugins must be loaded before core
    get_alpine_core_dep(),
    get_bridge_dep(),
    create_register_stores_script(stores)
  )
}


#' pre-registers stores to avoid "undefined" errors
#' @noRd
create_register_stores_script <- function(stores) {
  if (is.null(stores)) {
    return(NULL)
  }
  registry <- paste0(sprintf("Alpine.store('%s', {});", stores), collapse = " ")

  tags$script(HTML(
    sprintf("document.addEventListener('alpine:init', () => { %s })", registry)
  ))
}


get_alpine_core_dep <- function() {
  base_url <- sprintf(
    "%s/alpinejs@%s/dist/",
    .globals$alpine_cdn_base,
    .globals$alpine_version
  )

  htmltools::htmlDependency(
    name = "alpine-core",
    version = .globals$alpine_version,
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
    .globals$alpine_cdn_base,
    pkg_name,
    .globals$alpine_version
  )

  htmltools::htmlDependency(
    name = paste0("alpine-", plugin_name),
    version = .globals$alpine_version,
    src = c(href = base_url),
    script = list(src = "cdn.min.js", defer = NA)
  )
}


get_bridge_dep <- function() {
  htmltools::htmlDependency(
    name = "alpine-shiny-bridge",
    version = "0.0.1",
    src = c(file = system.file("js", package = "sherpa")),
    script = "alpine-shiny-bridge.js"
  )
}

#' Access an Alpine Store
#'
#' Helper to generate the `$store` syntax for Alpine stores.
#'
#' @param store_id Unique ID of the store.
#' @param prop Optional property within the store.
#' @return A string: `$store.store_id.prop`.
#' @export
s_store <- function(store_id, prop = NULL) {
  if (is.null(prop)) {
    return(sprintf("$store.%s", store_id))
  }
  sprintf("$store.%s.%s", store_id, prop)
}


#' Create $persist Magic
#'
#' Helper to generate the `$persist` magic for Alpine.js.
#'
#' @param value The initial value. This is automatically converted to JSON.
#' @param as Character. Optional: A custom key name for the storage.
#' @param using Character. Optional: The storage provider (e.g., 'sessionStorage').
#' @export
s_persist <- function(value, as = NULL, using = NULL) {
  assert_plugin_active("persist")

  out <- sprintf("$persist(%s)", to_json(value))

  if (!is.null(as)) {
    out <- sprintf("%s.as('%s')", out, as)
  }

  if (!is.null(using)) {
    out <- sprintf("%s.using(%s)", out, using)
  }

  structure(
    list(
      value = value,
      text = out,
      `__sherpa_config` = list(
        is_persistent = TRUE,
        as = as,
        using = using
      )
    ),
    class = c("sherpa_magic", "list")
  )
}


#' @export
as.character.sherpa_magic <- function(x, ...) {
  x$text
}

#' Create a Sherpa Store
#'
#' This constructor creates an S3 object that behaves like a native
#' reactiveValues list but stays synchronized with an Alpine.js store in the browser.
#'
#' @param id Unique identifier for the store (accessed as $store.id in JS)
#' @param data Initial data as a named list
#' @param session The Shiny session object
#'
#' @export
store <- function(
  id,
  data = list(),
  session = shiny::getDefaultReactiveDomain()
) {
  if (is.null(session)) {
    stop("Store must be initialized within a Shiny session.")
  }

  state <- rlang::new_environment(list(
    id = id,
    session = session,
    hold_sync = TRUE,
    values = shiny::reactiveValues()
  ))

  store <- structure(list(), state = state, class = "sherpa_store")

  process <- \(x) if (inherits(x, "sherpa_magic")) x$value else x

  for (key in names(data)) {
    stored_value <- process(data[[key]])
    #store[[key]] <- stored_value
  }

  state$hold_sync <- FALSE

  data <- to_json(data)

  session$sendCustomMessage(
    "sherpa-store-init",
    list(
      storeId = id,
      data = data
    )
  )

  input_id <- paste0("sherpa_update_", id)
  shiny::observeEvent(
    session$input[[input_id]],
    {
      msg <- session$input[[input_id]]

      state$hold_sync <- TRUE
      store[[msg$key]] <- msg$value
      state$hold_sync <- FALSE
    },
    ignoreInit = TRUE
  )

  return(store)
}


#' @export
`$.sherpa_store` <- function(x, name) {
  attr(x, "state")$values[[name]]
}


#' @export
`[[.sherpa_store` <- function(x, i, ...) {
  attr(x, "state")$values[[i]]
}


#' @export
`$<-.sherpa_store` <- function(x, name, value) {
  state <- attr(x, "state")
  state$values[[name]] <- value

  if (!state$hold_sync) {
    payload <- stats::setNames(list(value), name)
    state$session$sendCustomMessage(
      "sherpa-store-update",
      list(
        storeId = state$id,
        data = payload
      )
    )
  }
  return(x)
}

#' @export
`[[<-.sherpa_store` <- function(x, i, value) {
  `$<-.sherpa_store`(x, i, value)
}


#' @export
print.sherpa_store <- function(x, ...) {
  state <- attr(x, "state")
  cat(sprintf("<Sherpa Store [%s]>\n", state$id))
  print(shiny::reactiveValuesToList(state$values))
}

#' Alpine.js Store Manager
#'
#' Manages a synchronized state between R and an Alpine.js store.
#'
#' @export
AlpineStore <- R6::R6Class(
  "AlpineStore",
  public = list(
    #' @field data Holds the values available in the store. Read and write like `reactiveValues()`
    data = NULL,

    #' Initialize Instance
    #' @param id Unique identifier for the store (used in $store.id)
    #' @param session The Shiny session object
    #' @param data Named list with keys and values to populate store on initialisation
    initialize = function(
      id,
      session = shiny::getDefaultReactiveDomain(),
      data = NULL
    ) {
      private$id <- id
      private$session <- session %||%
        stop("Must initialize within Shiny session or provide session object.")

      private$init_data(data)
      private$start_processing_updates()

      invisible(self)
    }
  ),

  private = list(
    # @field id The store's ID (will be the same in the Client)
    id = NULL,

    # @field session The Shiny session
    session = NULL,

    # @field hold_sync Logical. If FALSE, updates to `storage`` will not be synced to Alpine, to avoid loops
    hold_sync = FALSE,

    # @description Populate store
    # @param data Named list
    init_data = function(data) {
      self$data <- new_rv_with_callbacks(
        on_set = \(name, value) {
          logger::log_debug("{ name } was set in store { private$id }")
          private$update_alpine(name, value)
        },
        on_get = \(name) {
          logger::log_debug("{ name } was retrieved from store { private$id }")
        },
      )

      for (key in names(data)) {
        self$data[[key]] <- data[[key]]
      }

      private$session$sendCustomMessage(
        "sherpa-store-init",
        list(
          storeId = private$id,
          data = data
        )
      )

      invisible(self)
    },

    # Observe client-side updates
    # custom message has form `list(key = <string>, value = <any>)`
    start_processing_updates = function() {
      input_id <- paste0("sherpa_update_", private$id)
      shiny::observeEvent(
        private$session$input[[input_id]],
        {
          msg <- private$session$input[[input_id]]
          private$hold_sync <- TRUE
          self$data[[msg$key]] <- msg$value
          private$hold_sync <- FALSE
        },
        ignoreInit = TRUE
      )
    },

    # @description Send a direct update to the Alpine store (unless hold_sync == TRUE)
    # @param key Property name
    # @param value The value to send (will be converted to JSON)
    update_alpine = function(key, value) {
      if (private$hold_sync) {
        return(invisible(self))
      }

      payload <- list()
      payload[[key]] <- value

      private$session$sendCustomMessage(
        "sherpa-store-update",
        list(
          storeId = private$id,
          data = payload
        )
      )

      invisible(self)
    }
  )
)


new_rv_with_callbacks <- function(..., on_get = NULL, on_set = NULL) {
  rv <- shiny::reactiveValues(...)

  structure(
    list(
      internal_rv = rv,
      on_get = on_get,
      on_set = on_set
    ),
    class = "rv_with_callbacks"
  )
}

# --- Getter Methods ---

#' @export
`$.rv_with_callbacks` <- function(x, name) {
  raw <- unclass(x)
  if (is.function(raw$on_get)) {
    raw$on_get(name)
  }
  raw$internal_rv[[name]]
}

#' @export
`[[.rv_with_callbacks` <- function(x, i, ...) {
  raw <- unclass(x)
  if (is.function(raw$on_get)) {
    raw$on_get(i)
  }
  raw$internal_rv[[i]]
}

# --- Setter Methods ---

#' @export
`$<-.rv_with_callbacks` <- function(x, name, value) {
  raw <- unclass(x)
  if (is.function(raw$on_set)) {
    raw$on_set(name, value)
  }
  raw$internal_rv[[name]] <- value
  x
}

#' @export
`[[<-.rv_with_callbacks` <- function(x, i, value) {
  raw <- unclass(x)
  if (is.function(raw$on_set)) {
    raw$on_set(i, value)
  }
  raw$internal_rv[[i]] <- value
  x
}

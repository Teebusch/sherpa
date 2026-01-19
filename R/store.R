#' Alpine.js Store Manager
#'
#' This class manages a synchronized state between R and an Alpine.js store.
#'
#' @export
AlpineStore <- R6::R6Class(
  "AlpineStore",
  public = list(
    id = NULL,
    session = NULL,

    #' @description Initialize a new Alpine Store
    #' @param id Unique identifier for the store (used in $store.id)
    #' @param session The Shiny session object
    initialize = function(id, session = shiny::getDefaultReactiveDomain()) {
      if (is.null(session)) {
        stop(
          "[Sherpa] AlpineStore must be initialized within a Shiny server function or provided with a session object."
        )
      }
      self$id <- id
      self$session <- session
    },

    #' @description Bind a reactive expression to a store property
    #' @param name The name of the property in the Alpine store
    #' @param reactive_expr A reactive expression or a value
    sync = function(name, reactive_expr) {
      shiny::observe({
        value <- if (shiny::is.reactive(reactive_expr)) {
          reactive_expr()
        } else {
          reactive_expr
        }
        self$update(name, value)
      })
      invisible(self)
    },

    #' @description Send a direct update to the store
    #' @param name Property name
    #' @param value The value to send (will be converted to JSON)
    update = function(name, value) {
      payload <- list()
      payload[[name]] <- value

      self$session$sendCustomMessage(
        "alpine-store-sync",
        list(
          storeId = self$id,
          data = payload,
          initial = FALSE
        )
      )
    },

    #' @description Initialize the store with a full set of data
    #' @param data A named list of initial values
    init = function(data = list()) {
      self$session$sendCustomMessage(
        "alpine-store-sync",
        list(
          storeId = self$id,
          data = data,
          initial = TRUE
        )
      )
      invisible(self)
    }
  )
)

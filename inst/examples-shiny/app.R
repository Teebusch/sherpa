library(shiny)
devtools::load_all()

ui <- fluidPage(
  # Matches the 'id' passed to the store() function in server
  use_alpine(stores = "appData"),

  tags$head(
    tags$style("[x-cloak] { display: none !important; }")
  ),

  s$div(
    style = "max-width: 800px; margin: auto; padding: 20px;",
    x_data("{ newItem: '', showSettings: false, color: '#007bff' }"),
    x_cloak(),

    s$header(
      s$h1("Sherpa v0.1 Demo", x_bind("style", "{ color: color }")),
      s$hr()
    ),

    s$section(
      class = "mb-4",
      s$h3("Task List (Synced to R)"),
      s$div(
        class = "input-group mb-2",
        s$input(
          type = "text",
          class = "form-control",
          placeholder = "Add a task...",
          x_model("newItem"),
          x_on(
            "keyup.enter",
            "if(newItem) { $store.appData.items.push(newItem); newItem = '' }"
          )
        ),
        s$button(
          class = "btn btn-primary",
          "Add",
          x_click(
            "if(newItem) { $store.appData.items.push(newItem); newItem = '' }"
          )
        )
      ),

      s$ul(
        class = "list-group",
        s$template(
          x_for("item in $store.appData.items"),
          s$li(
            class = "list-group-item d-flex justify-content-between",
            s$span(x_text("item")),
            s$button(
              "Delete",
              class = "btn btn-danger btn-sm",
              x_click(
                "$store.appData.items = $store.appData.items.filter(i => i !== item)"
              )
            )
          )
        )
      )
    ),

    s$section(
      class = "mb-4",
      s$h3("Server-Sent State"),
      s$div(
        class = "alert alert-info",
        s$strong("Status: "),
        s$span(x_text(x_store_ref("appData", "status"))),
        s$br(),
        s$small(
          "Current Server Time: ",
          s$span(x_text(x_store_ref("appData", "time")))
        )
      )
    ),

    s$section(
      class = "mb-4",
      s$h3("Frontend-Sent State (R Print)"),
      shiny::verbatimTextOutput("print_list")
    )
  )
)

server <- function(input, output, session) {
  app_state <- store(
    id = "appData",
    data = list(
      status = "Connecting...",
      time = "00:00:00",
      items = list('Eat', 'Code', 'Repeat')
    )
  )

  # Updates behave exactly like reactiveValues
  observe({
    invalidateLater(1000)
    app_state$time <- format(Sys.time(), "%H:%M:%S")
    app_state$status <- "Connection Active"
  })

  output$print_list <- shiny::renderPrint({
    req(app_state$items)
    cat("Items currently in R memory:\n")
    print(unlist(app_state$items))
  })
}

shinyApp(ui, server)

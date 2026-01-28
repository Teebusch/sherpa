library(shiny)
devtools::load_all()

ui <- fluidPage(
  use_alpine(stores = "app"),

  s$div(
    x_data(),
    s$h3("Status: ", s$span(x_text("$store.app.status"))),
    s$ul(
      s$template(
        x_for("task in $store.app.tasks"),
        s$li(x_text("task"))
      )
    ),
    actionButton("add", "Add Task from R")
  )
)

server <- function(input, output, session) {
  # Create a synced S3 store
  app_state <- store(
    "app",
    data = list(
      status = "Waiting...",
      tasks = list("Learn Alpine", "Install Sherpa")
    )
  )

  # Update the store directly - Alpine mirrors this instantly!
  observeEvent(input$add, {
    app_state$status <- "Updating..."
    app_state$tasks <- c(app_state$tasks, paste("New Task", Sys.time()))
  })
}

shinyApp(ui, server)

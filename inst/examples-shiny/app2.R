library(shiny)

rlang::check_installed("bslib")

devtools::load_all()
shiny::devmode(TRUE)

ui <- bslib::page_fluid(
  use_alpine(stores = "app", plugins = c("persist", "sort")),

  s$div(
    x_data(),
    s$div(
      s$button(
        class = "btn btn-default",
        "Clear Local Storage",
        x_click("localStorage.clear(); location.reload();")
      ),
      actionButton("add", "Add Task from R"),
      s$div(
        class = "input-group",
        x_data("{ newTask: '' }"),
        s$input(
          class = "form-control",
          x_model("newTask"),
          placeholder = "Client task..."
        ),
        s$button(
          "Add from Client",
          class = "btn btn-default",
          x_click(
            "if (newTask) { $store.app.tasks.push(newTask); newTask = ''; }"
          )
        )
      )
    ),
    s$ul(
      x_sort("$store.app.tasks = $event.target.querySelectorAll('li').map(el => el.innerText)"),
      s$template(
        x_for("task in $store.app.tasks"),
        s$li(x_text("task"))
      )
    )
  )
)

server <- function(input, output, session) {
  # Create a synced S3 store
  app_state <- store(
    "app",
    data = list(
      tasks = s_persist(list("Learn Alpine", "Install Sherpa"))
    )
  )

  # Update the store directly - Alpine mirrors this instantly!
  observeEvent(input$add, {
    app_state$tasks <- c(app_state$tasks, get_random_task())
  })
}


get_random_task <- function() {
  verbs <- c("eat", "see", "climb", "update", "repair", "build", "visit")
  nouns <- c("food", "house", "bike", "code", "car", "tree", "bridge")

  v <- sample(verbs, 1L)
  n <- sample(nouns, 1L)

  return(paste(v, n))
}

shinyApp(ui, server)

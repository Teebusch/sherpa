library(shiny)
devtools::load_all()

ui <- fluidPage(
  use_alpine(stores = "serverState"),

  # Custom CSS for x-cloak (prevents flicker)
  tags$head(
    tags$style("[x-cloak] { display: none !important; }")
  ),

  s$div(
    style = "max-width: 800px; margin: auto; padding: 20px;",
    x_data(
      "{ 
      newItem: '',
      items: ['Build Alpine Bridge', 'Fix Splicing Logic', 'Write Demo App'],
      showSettings: false,
      color: '#007bff'
    }"
    ),
    x_cloak(),

    s$header(
      s$h1("Sherpa v0.1 Demo", x_bind("style", "{ color: color }")),
      s$hr()
    ),

    # Local State & Loops (x-model & x-for)
    s$section(
      class = "mb-4",
      s$h3("Task List (Local)"),
      s$div(
        class = "input-group mb-2",
        s$input(
          type = "text",
          class = "form-control",
          placeholder = "Add a task...",
          x_model("newItem"),
          x_on(
            "keyup.enter",
            "if(newItem) { items.push(newItem); newItem = '' }"
          )
        ),
        s$button(
          class = "btn btn-primary",
          "Add",
          x_click("if(newItem) { items.push(newItem); newItem = '' }")
        )
      ),

      s$ul(
        class = "list-group",
        s$template(
          x_for("item in items"),
          s$li(
            class = "list-group-item d-flex justify-content-between",
            s$span(x_text("item")),
            s$button(
              "Delete",
              class = "btn btn-danger btn-sm",
              x_click("items = items.filter(i => i !== item)")
            )
          )
        )
      )
    ),

    # Settings & Transition
    s$section(
      s$h3("Settings"),
      s$button(
        "Toggle Settings",
        class = "btn btn-sm btn-outline-secondary",
        x_click("showSettings = !showSettings")
      ),

      s$template(
        x_if("showSettings"),
        s$div(
          x_transition(),
          style = "background: #f8f9fa; padding: 15px; margin-top: 10px; border-radius: 5px;",
          s$label("Header Color:"),
          s$input(
            type = "color",
            x_model("color"),
            class = "form-control-color"
          )
        )
      )
    ),

    # Store Sync (Server -> Client)
    s$section(
      class = "mb-4",
      s$h3("Server-Sent State"),
      s$div(
        class = "alert alert-info",
        s$strong("From R: "),
        s$span(x_text(x_store_ref("serverData", "status"))),
        s$br(),
        s$small(
          "Current Server Time: ",
          s$span(x_text(x_store_ref("serverData", "time")))
        )
      )
    )
  )
)

server <- function(input, output, session) {
  # Initialize the Server Store
  store <- AlpineStore$new("serverData")

  observe({
    invalidateLater(1000)
    store$update("time", format(Sys.time(), "%H:%M:%S"))
    store$update("status", "Connection Active")
  })

  store$init(list(status = "Connecting...", time = "00:00:00"))
}

shinyApp(ui, server)

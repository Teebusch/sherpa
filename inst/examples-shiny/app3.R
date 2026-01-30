library(shiny)
devtools::load_all()

ui <- fluidPage(
  use_alpine(plugins = c("mask", "collapse", "intersect", "sort")),

  tags$head(
    tags$style(
      "
      .sort-ghost { opacity: 0.3; background: #f8f9fa; }
      .drag-item { cursor: grab; transition: transform 0.1s; }
      .drag-item:active { cursor: grabbing; }
    "
    )
  ),

  s$div(
    class = "container py-5",
    x_data(
      "{ show_form: false, phone: '', items: ['Pizza', 'Tacos', 'Sushi'] }"
    ),

    s$h1("Sherpa Plugin Kitchen Sink"),
    s$hr(),

    # Intersect & Collapse
    s$section(
      class = "mb-5",
      s$h3("1. Viewport & Transitions"),
      s$div(
        class = "p-4 border bg-light",
        x_intersect("console.log('Visible!'); show_form = true", once = TRUE),

        s$button(
          "Toggle Masked Form",
          class = "btn btn-primary mb-3",
          x_click("show_form = !show_form")
        ),

        s$div(
          x_show("show_form"),
          x_collapse(duration = "400ms"),

          # Mask Plugin
          s$label("Phone Number Mask:"),
          s$input(
            class = "form-control w-50",
            x_model("phone"),
            x_mask("(999) 999-9999")
          ),
          s$p("Value in R: ", s$span(x_text("phone"), class = "fw-bold"))
        )
      )
    ),

    # Sort Plugin
    s$section(
      s$h3("2. Drag & Drop Sorting"),
      s$ul(
        class = "list-group w-50",
        x_sort(),

        s$template(
          x_for("item in items"),
          s$li(
            class = "list-group-item drag-item d-flex justify-content-between",
            s$span(x_text("item")),
            s$span("⋮", class = "text-muted")
          )
        )
      ),
      s$p(
        class = "mt-2 text-muted",
        "Try dragging the items above to reorder them."
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)

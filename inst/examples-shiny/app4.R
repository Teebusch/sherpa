library(shiny)
devtools::load_all()

template <- "./inst/examples-shiny/template.html"
ui <- html_template(
  template,
  stores = "app",
  plugins = "mask"
)

server <- function(input, output, session) {
  print(fs::dir_ls())

  watch(template) # Activate HMR

  app_state <- store(
    "app",
    data = list(
      title = "Sherpa HMR Demo",
      count = 0
    )
  )

  observeEvent(app_state$count, {
    print(paste("Count is now:", app_state$count))
  })
}

shinyApp(ui, server)

# sherpa

**sherpa** is a lightweight bridge between **R Shiny** and
**Alpine.js**. It allows you to build highly reactive user interfaces by
handling state and transitions in the browser while keeping your
business logic in R.

## Key Features

- The `s$` Proxy: A “Sherpa-aware” version of
  [`shiny::tags`](https://rstudio.github.io/htmltools/reference/builder.html)
  that automatically handles Alpine attributes without the need for the
  `!!!` (unquote-splice) operator.

- R-Native Directives: All core Alpine.js directives (`x-data`,
  `x-model`, `x-for`, etc.) available as standard R functions.

- TODO: AlpineStore (R6): Seamlessly sync server-side R reactive values
  to Alpine.js global stores.

- TODO: Auto-Binding: Automatically handles Shiny input/output binding
  for dynamically generated Alpine content.

- TODO: Supports Alpine.js Plugins, with special accomodations for
  Alpine AJAX

## Installation

You can install the development version of sherpa like so:

``` r
devtools::install_github("teebusch/sherpa")
```

## Quick Start

### 1. Simple Counter (Pure Frontend)

Use the `s$` proxy to inject Alpine logic directly into your UI.

``` r
library(shiny)
library(sherpa)

ui <- fluidPage(
  use_alpine(),
  s$div(
    x_data("{ count: 0 }"),
    s$h2("Counter: ", s$span(x_text("count"))),
    s$button("Increment", x_click("count++"), class = "btn btn-primary")
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
```

### 2. Server-Synced State (AlpineStore)

``` r
ui <- fluidPage(
  use_alpine(stores = "status"),
  s$div(
    s$h3("Server Status: ", s$span(x_text("$store.status.label"))),
    s$div(
      x_bind("class", "$store.status.connected ? 'text-success' : 'text-danger'"),
      x_text("$store.status.message")
    )
  )
)

server <- function(input, output, session) {
  # Initialize Store
  app_state <- AlpineStore$new("status")
  app_state$init(list(label = "Pending", connected = FALSE, message = "Waiting..."))
  
  # Update from R
  observe({
    invalidateLater(2000)
    app_state$update("label", "Live")
    app_state$update("connected", TRUE)
    app_state$update("message", paste("Last sync:", Sys.time()))
  })
}
```

## The “Way of the Sherpa” (Rules of Engagement)

- Use the Proxy: Always use s$tag_{n}ame{()}(e.g.,s$div()) instead of
  tags\$div() when you want to pass x\_ helpers.

- No Bangs: Because of the `s$` proxy, you do not need the `!!!`
  operator. Just pass the helper: `s$div(x_data(NA))`.

- Declare Stores: Pass your store names to use_alpine(stores =
  c(“myStore”)) to prevent “undefined” errors during page load.

## Available Helpers

| R Helper                                                                        | Alpine directive | What it does                                                  |
|---------------------------------------------------------------------------------|------------------|---------------------------------------------------------------|
| [`x_data()`](https://teebusch.github.io/sherpa/reference/x_data.md)             | `x-data`         | Defines a component and its reactive data.                    |
| [`x_model()`](https://teebusch.github.io/sherpa/reference/x_model.md)           | `x-model`        | Creates two-way data binding on input elements.               |
| [`x_transition()`](https://teebusch.github.io/sherpa/reference/x_transition.md) | `x-transition`   | Applies smooth CSS transitions for entries and exits.         |
| [`x_text()`](https://teebusch.github.io/sherpa/reference/x_text.md)             | `x-text`         | Updates the inner text of an element dynamically.             |
| [`x_show()`](https://teebusch.github.io/sherpa/reference/x_show.md)             | `x-show`         | Toggles visibility via CSS (display: none).                   |
| [`x_on()`](https://teebusch.github.io/sherpa/reference/x_on.md)                 | `x-on`           | Listens for browser events (shortcut: `x_click`, `x_change`). |
| [`x_bind()`](https://teebusch.github.io/sherpa/reference/x_bind.md)             | `x-bind`         | Dynamically binds HTML attributes (e.g. class, disabled).     |
| [`x_if()`](https://teebusch.github.io/sherpa/reference/x_if.md)                 | `x-if`           | Conditionally adds/removes elements (must use `<template>`).  |
| [`x_for()`](https://teebusch.github.io/sherpa/reference/x_for.md)               | `x-for`          | Loops over data to create elements (must use `<template>`).   |
| [`x_init()`](https://teebusch.github.io/sherpa/reference/x_init.md)             | `x-init`         | Runs JavaScript code when the element is initialized.         |
| [`x_cloak()`](https://teebusch.github.io/sherpa/reference/x_cloak.md)           | `x-cloak`        | Hides elements until Alpine has finished loading.             |
| [`x_html()`](https://teebusch.github.io/sherpa/reference/x_html.md)             | `x-html`         | Updates the inner HTML of an element (use with caution).      |
| [`x_ref()`](https://teebusch.github.io/sherpa/reference/x_ref.md)               | `x-ref`          | Utility for accessing DOM-Elements directly.                  |

Attribute missing? Use
[`x_attr_builder()`](https://teebusch.github.io/sherpa/reference/x_attr_builder.md)
to create your own.

See the [Alpine Docs for more details](https://alpinejs.dev/directives/)

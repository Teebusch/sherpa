
# sherpa <img src="man/figures/logo.png" align="right" height="139"/>

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

**sherpa** carries your data between **R Shiny** and **Alpine.js**. It lets you build highly reactive user interfaces by synchronizing reactive values between a Shiny backend and an Alpine.js Frontend. This lets you handle UI-state and transitions in the browser while keeping your business logic in R.

## Key Features

- ✅ `s$`: A "Sherpa-aware" version of `shiny::tags` that automatically handles Alpine attributes without the need for lots of backticks or the `!!!` splice-operator.

- ✅ R-Native Directives: All core Alpine.js directives (`x-data`, `x-model`, `x-for`, etc.) available as standard R functions with support for modifiers and optional arguments.

- ✅ AlpineStore (R6): Sync server-side R reactive values to Alpine.js global stores.

- ✅ Sync changes in Alpine Store back to Shiny server as reactive values.

- 📋 TODO: Auto-Binding: Automatically handles Shiny input/output binding for dynamically generated Alpine content.

- 📋 TODO: Supports Alpine.js Plugins, with special accomodations for Alpine AJAX

- 📋 TODO: Examples of Sherpa in use

## Installation

You can install the development version of sherpa like this:

``` r
devtools::install_github("teebusch/sherpa")
```

## Quick Start

### A Simple Counter (Pure Frontend, no Store)

Use the `s$` proxy for Shiny-Tags to easily inject Alpine directives into your Shiny-UI.

```r
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

### Server-Synced State (via AlpineStore)

```r
library(shiny)
library(sherpa)

ui <- fluidPage(
  use_alpine(stores = "appState"),
  s$div(
    x_data(),
    s$h3("Server Status: ", s$span(x_text("$store.appState.label"))),
    s$div(
      x_bind("class", "$store.appState.connected ? 'text-success' : 'text-danger'"),
      x_text("$store.appState.message")
    )
  )
)

server <- function(input, output, session) {
  app_state <- AlpineStore$new(
    "appState",
    data = list(
      label = "Pending", 
      connected = FALSE, 
      message = "Waiting..."
    )
  )
  
  observe({
    invalidateLater(2000)
    app_state$data$label <- "Live"
    app_state$data$connected <- TRUE
    app_state$data$message <- paste("Last sync:", Sys.time())
  })
}

shinyApp(ui, server)
```

## The "Way of the Sherpa" (Rules of Engagement)

- Use the Proxy: Use s$tag_name() (e.g., s$div()) instead of tags$div() when you want to pass x_ helpers. Or, if you prefer, use the Sherpa operator `%s%`

- No Bangs: Because of the `s$` proxy, you do not need the `!!!` operator. Just pass the helper: `s$div(x_data(NA))`.

- Declare Stores: Pass your store names to use_alpine(stores = c("myStore")) to prevent "undefined" errors during page load.

## Available Directive Helpers

| R Helper         | Alpine directive | What it does                                                  |
|------------------|------------------|---------------------------------------------------------------|
| `x_data()`       | `x-data`         | Defines a component and its reactive data.                    |
| `x_bind()`       | `x-bind`         | Dynamically binds HTML attributes (e.g. class, disabled).     |
| `x_on()`         | `x-on`           | Listens for browser events (shortcut: `x_click`, `x_change`). |
| `x_text()`       | `x-text`         | Updates the inner text of an element dynamically.             |
| `x_html()`       | `x-html`         | Updates the inner HTML of an element (use with caution).      |
| `x_model()`      | `x-model`        | Creates two-way data binding on input elements.               |
| `x_show()`       | `x-show`         | Toggles visibility via CSS (display: none).                   |
| `x_transition()` | `x-transition`   | Applies smooth CSS transitions for entries and exits.         |
| `x_for()`        | `x-for`          | Loops over data to create elements (must use `<template>`).   |
| `x_if()`         | `x-if`           | Conditionally adds/removes elements (must use `<template>`).  |
| `x_init()`       | `x-init`         | Runs JavaScript code when the element is initialized.         |
| `x_effect()`     | `x-effect`       | Runs a script when a reactive dependency changes.             |
| `x_ref()`        | `x-ref`          | Utility for accessing DOM-Elements directly.                  |
| `x_cloak()`      | `x-cloak`        | Hides elements until Alpine has finished loading.             |
| `x_ignore `      | `x-cloak`        | Lets Alpine ignore an element.                                |
| `x_modelable()`  | `x-modelable`    | Expose Alpine properties as the target of x-model.            |

Directive missing? Use `x_attr_builder()` to create your own.

See the [Alpine Docs for more details](https://alpinejs.dev/directives/) 
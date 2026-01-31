
# sherpa <img src="man/figures/logo.png" align="right" height="139"/>

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

**sherpa** carries your data between **R Shiny** and **Alpine.js**. It lets you build highly reactive user interfaces by synchronizing reactive values between a Shiny backend and an Alpine.js Frontend. 

## Why Alpine.js?

[Alpine.js](https://alpinejs.dev/) is a rugged, minimal framework for composing behavior directly in your markup. It is the perfect partner for Shiny because it is great at handling the "last mile" of the user experience and it integrates nicely into Shiny and the Shiny development workflow.

In a standard Shiny app, the server often manages micro-interactions and things like disabling a button or hiding an element can be surprisingly cumbersome to implement. Sherpa's goal is to take some of that weight from Shiny's shoulders, so Shiny can do what it does best: heavy-duty data processing, complex business logic, and deep integration with the R ecosystem while Alpine.js handles the "fast-twitch" reflexes: UI state, smooth transitions, and client-side interactions that happen at the speed of thought.

## Key Features

- ✅ Synced Stores: Create a store in R with store(). It behaves like a native reactiveValues list but automatically mirrors its state to Alpine.js in the browser.

- ✅ Bi-Directional Sync: Change a value in R, and the UI updates. Change a value in Alpine (via x-model or logic), and R sees the change immediately.

- ✅ R-Native Directives: All core Alpine.js directives (`x-data`, `x-model`, `x-for`, etc.) and some of the official plugins available as standard R functions with support for modifiers and optional arguments. Gives you a sense of IntelliSense when writing Alpine Directives in Shiny UI Code. Directive helpers are complemented by `s$`, a "Sherpa-aware" version of `shiny::tags` that automatically handles Alpine directive helpers without the need for backticks or the `!!!` splice-operator.

- ✅ Support for HTML-Templates, so you can write your Alpine.js code in an HTML file and leverage the power of IntelliSense. Plus: there's an experimental Live-Server with HMR, that renders your changes instantly while maintaining the current state.

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
    class = "p-5",
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
  app_state <- store("app", data = list(
    status = "Waiting...",
    tasks = list("Learn Alpine", "Install Sherpa")
  ))

  # Update the store directly - Alpine mirrors this instantly!
  observeEvent(input$add, {
    app_state$status <- "Updating..."
    app_state$tasks <- c(app_state$tasks, paste("New Task", Sys.time()))
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

### Directives from Plugins

Use `use_alpine(plugins = c(<PLUGIN_NAMES>))` to activate them.

| R Helper         | Alpine directive | What it does                                                  | Plugin    |
|------------------|------------------|---------------------------------------------------------------|-----------|
| `x_intersect()`  | `x-intersect`    | React when an element enters the viewport.                    | intersect |
| `x_sort()`       | `x-sort`         | Re-order elements by dragging them with your mouse.           | sort      |
| `x_collapse()`   | `x-collapse`     | Expand and collapse elements.                                 | collapse  |
| `x_mask()`       | `x-mask`         | Automatically format input fields (phone, dates, etc.).       | mask      |
| `x_trap()`       | `x-trap`         | Trap keyboard focus within an element (for modals).           | focus     |
| `x_anchor()`     | `x-anchor`       | Position an element relative to another reference element.    | anchor    |
| `x_resize()`     | `x-resize`       | Execute JavaScript whenever an element's size changes.        | resize    |


Directive missing? Use `x_attr_builder()` to create your own.

See the [Alpine Docs for more details](https://alpinejs.dev/directives/) 
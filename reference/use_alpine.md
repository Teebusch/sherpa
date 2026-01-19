# Activate Alpine.js and plugins in Shiny app

Add this anywhere in your UI. Shiny will take care of hoisting it into
your HTML page's `<head>`.

## Usage

``` r
use_alpine(plugins = NULL, stores = NULL)
```

## Arguments

- plugins:

  Character vector with Alpine plugin names (e.g. c("persist", "mask",
  "intersect")).

## Value

A
[`htmltools::tagList`](https://rstudio.github.io/htmltools/reference/tagList.html)
with the dependencies as
[htmltools::htmlDependency](https://rstudio.github.io/htmltools/reference/htmlDependency.html).

## Examples

``` r
if (FALSE) { # \dontrun{
ui <- fluidPage(
  use_alpine(plugins = c("mask", "persist")),
  div(x_data("{ open: false }"), ...)
)
} # }
```

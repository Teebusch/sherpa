# Create a Sherpa UI from an HTML Template

Create a Sherpa UI from an HTML Template

## Usage

``` r
html_template(path, stores = NULL, plugins = NULL, ...)
```

## Arguments

- path:

  Path to the .html file

- stores:

  Character vector of names of stores that will be used. Must be
  initialized here.

- plugins:

  Character vector with Alpine plugin names (e.g. c("persist", "mask",
  "intersect")).

- ...:

  Additional variables to pass to the template (accessible via
  `{{ var }}`)

## See also

[`shiny::htmlTemplate()`](https://rdrr.io/pkg/shiny/man/reexports.html)

# Create a Sherpa Store

This constructor creates an S3 object that behaves like a native
reactiveValues list but stays synchronized with an Alpine.js store in
the browser.

## Usage

``` r
store(id, data = list(), session = shiny::getDefaultReactiveDomain())
```

## Arguments

- id:

  Unique identifier for the store (accessed as \$store.id in JS)

- data:

  Initial data as a named list

- session:

  The Shiny session object

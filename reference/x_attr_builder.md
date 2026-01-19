# Helper to construct Alpine.js attributes

Helper to construct Alpine.js attributes

## Usage

``` r
x_attr_builder(directive, value, modifiers = NULL, arg = NULL)
```

## Arguments

- directive:

  The base directive name (e.g., "model", "on")

- value:

  The value assigned to the attribute. Use `NA` for boolean attributes.

- modifiers:

  Optional character vector of modifiers (e.g., c("prevent", "stop"))

- arg:

  Optional argument for the directive (e.g., "click" for x-on)

## Value

An S3 object of class `sherpa_attr` (a named list).

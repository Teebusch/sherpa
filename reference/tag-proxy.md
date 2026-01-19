# The Sherpa Tag Proxy

An environment containing wrappers for all shiny::tags. These wrappers
automatically handle sherpa attribute helpers (like
[`x_data()`](https://teebusch.github.io/sherpa/reference/x_data.md),
[`x_on()`](https://teebusch.github.io/sherpa/reference/x_on.md), ...)
without the need for the
[rlang::splice-operator](https://rlang.r-lib.org/reference/splice-operator.html)
`!!!`.

## Usage

``` r
s
```

## Format

An object of class `environment` of length 181.

## Details

The sherpa attribute helpers all return a named list with a single
Element. By default,
[shiny::tags](https://rdrr.io/pkg/shiny/man/reexports.html) will treat
these named lists as regular tag content instead of HTML-Attributes
(which we want).

There are 3 ways to make
[shiny::tags](https://rdrr.io/pkg/shiny/man/reexports.html) treat the
sherpa attribute helpers as HTML-attributes:

- `splice` them into the function call using
  [rlang::splice-operator](https://rlang.r-lib.org/reference/splice-operator.html)
  `!!!`

- add them using
  [`%s%`](https://teebusch.github.io/sherpa/reference/sherpa_operator.md),
  a wrapper for
  [shiny::tagAppendAttributes](https://rdrr.io/pkg/shiny/man/reexports.html)
  that automatically splices sherpa attribute helpers

- using this "tag proxy". It proxies the
  [`shiny::tags`](https://rstudio.github.io/htmltools/reference/builder.html)-Object
  but adds automatic splicing for sherpa attribute helpers.

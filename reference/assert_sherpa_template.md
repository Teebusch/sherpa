# Sanity checks for Sherpa HTML Template

Ensures `{{ headContent() }}` and `x-data` are present. This ensures the
template works correctly with Sherpa and Shiny

## Usage

``` r
assert_sherpa_template(path)
```

## Value

The original path if valid, otherwise aborts.

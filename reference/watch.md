# Activate Hot Module Reloading for a HTML-Template

Run within your server function to register a a watcher for a
HTML-Template. Usually the same template that is supplie to the ui via
[`html_template()`](https://teebusch.github.io/sherpa/reference/html_template.md)

## Usage

``` r
watch(path, interval = 0.3, session = shiny::getDefaultReactiveDomain())
```

## Arguments

- path:

  Path to the HTML template to monitor.

- interval:

  How often to check for changes in seconds.

- session:

  The Shiny session object.

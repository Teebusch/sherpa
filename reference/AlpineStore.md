# Alpine.js Store Manager

Manages a synchronized state between R and an Alpine.js store.

## Public fields

- `data`:

  Holds the values available in the store. Read and write like
  [`reactiveValues()`](https://rdrr.io/pkg/shiny/man/reactiveValues.html)
  Initialize Instance

## Methods

### Public methods

- [`AlpineStore$new()`](#method-AlpineStore-new)

- [`AlpineStore$clone()`](#method-AlpineStore-clone)

------------------------------------------------------------------------

### Method [`new()`](https://rdrr.io/r/methods/new.html)

#### Usage

    AlpineStore$new(id, session = shiny::getDefaultReactiveDomain(), data = NULL)

#### Arguments

- `id`:

  Unique identifier for the store (used in \$store.id)

- `session`:

  The Shiny session object

- `data`:

  Named list with keys and values to populate store on initialisation

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    AlpineStore$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

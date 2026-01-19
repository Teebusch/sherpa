# Alpine.js Store Manager

Alpine.js Store Manager

Alpine.js Store Manager

## Details

This class manages a synchronized state between R and an Alpine.js
store.

## Public fields

- `id`:

  The store's ID (will be the same in the Client)

- `session`:

  The Shiny session

## Methods

### Public methods

- [`AlpineStore$new()`](#method-AlpineStore-new)

- [`AlpineStore$sync()`](#method-AlpineStore-sync)

- [`AlpineStore$update()`](#method-AlpineStore-update)

- [`AlpineStore$init()`](#method-AlpineStore-init)

- [`AlpineStore$clone()`](#method-AlpineStore-clone)

------------------------------------------------------------------------

### Method [`new()`](https://rdrr.io/r/methods/new.html)

Initialize a new Alpine Store

#### Usage

    AlpineStore$new(id, session = shiny::getDefaultReactiveDomain())

#### Arguments

- `id`:

  Unique identifier for the store (used in \$store.id)

- `session`:

  The Shiny session object

------------------------------------------------------------------------

### Method `sync()`

Bind a reactive expression to a store property

#### Usage

    AlpineStore$sync(name, reactive_expr)

#### Arguments

- `name`:

  The name of the property in the Alpine store

- `reactive_expr`:

  A reactive expression or a value

------------------------------------------------------------------------

### Method [`update()`](https://rdrr.io/r/stats/update.html)

Send a direct update to the store

#### Usage

    AlpineStore$update(name, value)

#### Arguments

- `name`:

  Property name

- `value`:

  The value to send (will be converted to JSON)

------------------------------------------------------------------------

### Method `init()`

Initialize the store with a full set of data

#### Usage

    AlpineStore$init(data = list())

#### Arguments

- `data`:

  A named list of initial values

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    AlpineStore$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

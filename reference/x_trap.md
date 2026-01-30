# Alpine.js Focus Trap Directive

Trap focus within a specific DOM element (perfect for modals). Requires
Plugin "Focus"

## Usage

``` r
x_trap(expression, inertia = FALSE, noscroll = FALSE)
```

## Arguments

- expression:

  A JS expression evaluating to boolean (e.g., "isOpen")

- inertia:

  Logical, if TRUE, allows focus to move to browser chrome

- noscroll:

  Logical, if TRUE, prevents scrolling when focus is trapped

#' @importFrom rlang %||%
NULL

# ---------------------------------------------------------
# Internal Helpers
# ---------------------------------------------------------

#' Helper to construct Alpine.js attributes
#'
#' @param directive The base directive name (e.g., "model", "on")
#' @param value The value assigned to the attribute. Use `NA` for boolean attributes.
#' @param modifiers Optional character vector of modifiers (e.g., c("prevent", "stop"))
#' @param arg Optional argument for the directive (e.g., "click" for x-on)
#'
#' @return An S3 object of class `sherpa_attr` (a named list).
#' @export
x_attr_builder <- function(directive, value, modifiers = NULL, arg = NULL) {
  key <- paste0("x-", directive)

  if (!is.null(arg)) {
    key <- paste0(key, ":", arg)
  }

  if (!is.null(modifiers)) {
    mods_str <- paste(modifiers, collapse = ".")
    key <- paste0(key, ".", mods_str)
  }

  res <- list(value)
  names(res) <- key
  structure(res, class = c("sherpa_attr", "list"))
}

#' Check if an object is a Sherpa attribute
#' @noRd
is_sherpa_attr <- function(x) {
  inherits(x, "sherpa_attr")
}

# ---------------------------------------------------------
# Core Directives
# ---------------------------------------------------------

#' Define Alpine Component Data
#'
#' Provides reactive data for an Alpine component.
#'
#' @param data A JSON string (e.g., `"{ open: false }"`) or a store name.
#'   Use `NA` to create a data-less component.
#' @seealso <https://alpinejs.dev/directives/data>
#' @export
x_data <- function(data = "{}") {
  x_attr_builder("data", data)
}

#' Alpine Initialization Hook
#'
#' Execute JavaScript code during the initialization phase of an element.
#'
#' @param code JavaScript code string.
#' @seealso <https://alpinejs.dev/directives/init>
#' @export
x_init <- function(code) {
  x_attr_builder("init", code)
}

#' Toggle Visibility
#'
#' Show and hide DOM elements via the 'display: none' CSS property.
#'
#' @param condition JavaScript expression returning a boolean-like value.
#' @seealso <https://alpinejs.dev/directives/show>
#' @export
x_show <- function(condition) {
  x_attr_builder("show", condition)
}

#' Attribute Binding
#'
#' Bind HTML attributes based on JavaScript expressions.
#'
#' @param attr The HTML attribute to bind (e.g., "class", "disabled", "href").
#' @param expression JavaScript expression to evaluate.
#' @param modifiers Optional modifiers, such as "camel" for SVG attributes.
#' @seealso <https://alpinejs.dev/directives/bind>
#' @export
x_bind <- function(attr, expression, modifiers = NULL) {
  x_attr_builder("bind", expression, modifiers = modifiers, arg = attr)
}

#' Event Listener
#'
#' Listen for browser events and execute JavaScript code.
#'
#' @param event The event name (e.g., "click", "keyup", "submit").
#' @param code JavaScript code to execute.
#' @param modifiers Optional modifiers like "prevent", "stop", or "outside".
#' @seealso <https://alpinejs.dev/directives/on>
#' @export
x_on <- function(event, code, modifiers = NULL) {
  x_attr_builder("on", code, modifiers = modifiers, arg = event)
}

#' Bind Text Content
#'
#' Update the text content of an element automatically.
#'
#' @param expression JavaScript expression returning a string.
#' @seealso <https://alpinejs.dev/directives/text>
#' @export
x_text <- function(expression) {
  x_attr_builder("text", expression)
}

#' Bind HTML Content
#'
#' Update the inner HTML of an element.
#' **Warning:** Only use with trusted content to prevent XSS attacks.
#'
#' @param expression JavaScript expression returning an HTML string.
#' @seealso <https://alpinejs.dev/directives/html>
#' @export
x_html <- function(expression) {
  x_attr_builder("html", expression)
}

#' Two-Way Data Binding
#'
#' Bind the value of an input element to Alpine data.
#'
#' @param prop The property in the Alpine data object.
#' @param modifiers Modifiers like "debounce.500ms", "number", or "lazy".
#' @seealso <https://alpinejs.dev/directives/model>
#' @export
x_model <- function(prop, modifiers = NULL) {
  x_attr_builder("model", prop, modifiers = modifiers)
}

#' Expose Properties to x-model
#'
#' Make any Alpine property available as the target for `x-model`.
#'
#' @param prop The property to make modelable.
#' @seealso <https://alpinejs.dev/directives/modelable>
#' @export
x_modelable <- function(prop) {
  x_attr_builder("modelable", prop)
}

#' Hide Elements until Alpine is Loaded
#'
#' Prevents "flicker" by hiding elements before Alpine initializes.
#' Requires CSS: `[x-cloak] { display: none !important; }`
#'
#' @seealso <https://alpinejs.dev/directives/cloak>
#' @export
x_cloak <- function() {
  x_attr_builder("cloak", NA)
}

#' Conditional Rendering (x-if)
#'
#' Elements inside an x-if must be wrapped in a `<template>` tag.
#'
#' @param condition JavaScript expression.
#' @seealso <https://alpinejs.dev/directives/if>
#' @export
x_if <- function(condition) {
  x_attr_builder("if", condition)
}

#' Loop Through Data (x-for)
#'
#' Elements inside an x-for must be wrapped in a `<template>` tag.
#'
#' @param iteration Loop syntax, e.g., "item in items".
#' @param key_prop Optional property name to use as a unique key.
#' @seealso <https://alpinejs.dev/directives/for>
#' @export
x_for <- function(iteration, key_prop = NULL) {
  # Note: Alpine often requires :key for re-ordering DOM elements safely.
  # If a key_prop is provided, we'll suggest it in the documentation context.
  x_attr_builder("for", iteration)
}

#' Reactive Effects (x-effect)
#'
#' Run a script when a reactive dependency changes.
#'
#' @param code JavaScript code.
#' @seealso <https://alpinejs.dev/directives/effect>
#' @export
x_effect <- function(code) {
  x_attr_builder("effect", code)
}

#' Teleport DOM Elements
#'
#' Render an element's content in a different part of the DOM.
#'
#' @param selector CSS selector for the target destination (e.g., "body").
#' @seealso <https://alpinejs.dev/directives/teleport>
#' @export
x_teleport <- function(selector) {
  x_attr_builder("teleport", selector)
}

#' Ignore Element for Alpine
#'
#' Prevents Alpine from initializing or looking for directives inside an element.
#' Useful for integrating other JS libraries (like Leaflet or D3).
#'
#' @seealso <https://alpinejs.dev/directives/ignore>
#' @export
x_ignore <- function() {
  x_attr_builder("ignore", NA)
}

#' Utility for accessing DOM elements directly.
#'
#' It's most useful as a replacement for APIs like getElementById and querySelector.
#'
#' @param ref The reference to give the DOM-element.
#' @seealso <https://alpinejs.dev/directives/ref>
#' @export
x_ref <- function(ref) {
  x_attr_builder("ref", ref)
}

#' Generate Unique IDs
#'
#' Create unique IDs that can be referenced by multiple elements (e.g., aria-labelledby).
#'
#' @param id_name The name/key for the unique ID.
#' @seealso <https://alpinejs.dev/directives/id>
#' @export
x_id <- function(id_name) {
  x_attr_builder("id", id_name)
}

#' Apply CSS Transitions
#'
#' Smoothly transition elements as they enter/leave the DOM.
#'
#' @param modifiers Optional modifiers for specific stages (e.g., "enter", "leave", "duration.500ms").
#' @seealso <https://alpinejs.dev/directives/transition>
#' @export
x_transition <- function(modifiers = NULL) {
  x_attr_builder("transition", NA, modifiers = modifiers)
}

# ---------------------------------------------------------
# Convenience Shortcuts
# ---------------------------------------------------------

#' Click Event Shortcut
#'
#' Shortcut for `x-on:click`.
#'
#' @param code JavaScript code.
#' @param modifiers Event modifiers like "prevent" or "stop".
#' @export
x_click <- function(code, modifiers = NULL) {
  x_on("click", code, modifiers)
}

#' Change Event Shortcut
#'
#' Shortcut for `x-on:change`.
#'
#' @param code JavaScript code.
#' @param modifiers Event modifiers.
#' @export
x_change <- function(code, modifiers = NULL) {
  x_on("change", code, modifiers)
}

#' Access an Alpine Store
#'
#' Helper to generate the `$store` syntax for Alpine stores.
#'
#' @param store_id Unique ID of the store.
#' @param prop Optional property within the store.
#' @return A string: `$store.store_id.prop`.
#' @export
x_store_ref <- function(store_id, prop = NULL) {
  if (is.null(prop)) {
    return(sprintf("$store.%s", store_id))
  }
  sprintf("$store.%s.%s", store_id, prop)
}

# ---------------------------------------------------------
# Directives for official plugins
# ---------------------------------------------------------

#' Alpine.js Mask Directive
#'
#' Automatically format input fields as a user types.
#' Requires Plugin "Mask"
#'
#' @param mask The mask pattern (e.g., "99/99/9999")
#' @param quote Logical, if TRUE, wraps the mask in single quotes (needed for strings)
#' @seealso <https://alpinejs.dev/plugins/mask>
#' @export
x_mask <- function(mask, quote = TRUE) {
  assert_plugin_active("mask")

  if (quote && !grepl("^\\$", mask)) {
    mask <- sprintf("'%s'", mask)
  }

  x_attr_builder("mask", mask)
}

#' Alpine.js Focus Trap Directive
#'
#' Trap focus within a specific DOM element (perfect for modals).
#' Requires Plugin "Focus"
#'
#' @param expression A JS expression evaluating to boolean (e.g., "isOpen")
#' @param inertia Logical, if TRUE, allows focus to move to browser chrome
#' @param noscroll Logical, if TRUE, prevents scrolling when focus is trapped
#' @seealso <https://alpinejs.dev/plugins/focus>
#' @export
x_trap <- function(expression, inertia = FALSE, noscroll = FALSE) {
  assert_plugin_active("focus")

  directive <- "trap"
  if (inertia) {
    directive <- paste0(directive, ".inertia")
  }
  if (noscroll) {
    directive <- paste0(directive, ".noscroll")
  }

  x_attr_builder(directive, expression)
}

#' Alpine.js Anchor Directive
#'
#' Position an element relative to another "reference" element.
#' Requires Plugin "Anchor"
#'
#' @param ref The reference element (e.g., "$refs.button")
#' @param pivot The anchor point (e.g., "bottom-start", "top-end")
#' @param offset Offset in pixels
#' @seealso <https://alpinejs.dev/plugins/anchor>
#' @export
x_anchor <- function(ref, pivot = NULL, offset = NULL) {
  assert_plugin_active("anchor")

  directive <- "anchor"
  if (!is.null(pivot)) {
    directive <- paste0(directive, ".", pivot)
  }
  if (!is.null(offset)) {
    directive <- paste0(directive, ".offset.", offset)
  }

  x_attr_builder(directive, ref)
}

#' Alpine.js Resize Directive
#'
#' Execute code whenever an element's size changes.
#' Requires Plugin "Resize"
#'
#' @param expression The JS code to run when resized
#' @seealso <https://alpinejs.dev/plugins/resize>
#' @export
x_resize <- function(expression) {
  assert_plugin_active("resize")
  x_attr_builder("resize", expression)
}

#' Alpine.js Intersect Directive
#'
#' React when an element enters the viewport.
#' Requires Plugin "Intersect"
#'
#' @param expression The JS code to run on intersection
#' @param once Logical, if TRUE, only trigger the first time
#' @seealso <https://alpinejs.dev/plugins/intersect>
#' @export
x_intersect <- function(expression, once = FALSE) {
  assert_plugin_active("intersect")

  directive <- "intersect"
  if (once) {
    directive <- paste0(directive, ".once")
  }

  x_attr_builder(directive, expression)
}

#' Alpine.js Collapse Directive
#'
#' Expand and collapse elements using smooth animations.
#' Requires Plugin "Collapse"
#'
#' @param duration Optional duration (e.g., "500ms")
#' @param min Optional minimum height (e.g., "50px")
#' @seealso <https://alpinejs.dev/plugins/collapse>
#' @export
x_collapse <- function(duration = NULL, min = NULL) {
  assert_plugin_active("collapse")

  directive <- "collapse"
  if (!is.null(duration)) {
    directive <- paste0(directive, ".duration.", duration)
  }
  if (!is.null(min)) {
    directive <- paste0(directive, ".min.", min)
  }

  x_attr_builder(directive, NA)
}

#' Alpine.js Sort Directive
#'
#' Re-order elements by dragging them with your mouse.
#' Requires Plugin "Sort"
#'
#' @param group Optional group name to allow sorting between multiple lists
#' @param handle Optional selector for a drag handle (e.g., '.drag-handle')
#' @seealso <https://alpinejs.dev/plugins/sort>
#' @export
x_sort <- function(group = NULL, handle = NULL) {
  assert_plugin_active("sort")

  directive <- "sort"
  if (!is.null(group)) {
    directive <- paste0(directive, ".group.", group)
  }
  if (!is.null(handle)) {
    directive <- paste0(directive, ".handle.", handle)
  }

  # Usually used as x-sort on a parent container
  x_attr_builder(directive, NA)
}

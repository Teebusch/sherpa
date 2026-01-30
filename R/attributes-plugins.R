#' Alpine.js Mask Directive
#'
#' Automatically format input fields as a user types.
#' Requires Plugin "Mask"
#'
#' @param mask The mask pattern (e.g., "99/99/9999")
#' @param quote Logical, if TRUE, wraps the mask in single quotes (needed for strings)
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

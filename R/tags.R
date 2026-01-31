#' The Sherpa Tag Proxy
#'
#' An environment containing wrappers for all shiny::tags.
#' These wrappers automatically handle sherpa attribute helpers
#' (like [x_data()], [x_on()], ...) without the need for the
#' [rlang::splice-operator] `!!!`.
#'
#' @details
#' The sherpa attribute helpers all return a named list with
#' a single Element. By default, [shiny::tags] will treat these named
#' lists as regular tag content instead of HTML-Attributes (which we want).
#'
#' There are 3 ways to make [shiny::tags] treat the sherpa attribute helpers
#' as HTML-attributes:
#'
#' - `splice` them into the function call using [rlang::splice-operator] `!!!`
#' - add them using [sherpa_operator], a wrapper for [shiny::tagAppendAttributes]
#'   that automatically splices sherpa attribute helpers
#' - using this "tag proxy". It proxies the `shiny::tags`-Object but adds
#'   automatic splicing for sherpa attribute helpers.
#'
#' @name tag-proxy
NULL


#' Process sherpa attributes for HTML-Tags
#' @description
#' Looks for unnamed arguments of class 'sherpa_attr' and
#' flattens them into the main attribute list.
#' @noRd
process_sherpa_attrs <- function(...) {
  args <- list(...)

  is_unnamed <- !nzchar(names(args) %||% rep("", length(args)))
  is_sherpa <- vapply(args, function(x) inherits(x, "sherpa_attr"), logical(1))
  to_splice <- is_unnamed & is_sherpa

  if (!any(to_splice)) {
    return(args)
  }

  # Flatten sherpa_attr objects into the main argument list
  final_args <- list()
  for (i in seq_along(args)) {
    if (to_splice[i]) {
      final_args <- c(final_args, args[[i]])
    } else {
      final_args <- c(final_args, args[i])
    }
  }
  return(final_args)
}


# Pre-process the args to 'splice' sherpa_attr objects
# so they get added as tag attributes instead of tag content
create_tag_proxy <- function() {
  tag_funs <- as.list(shiny::tags)
  tag_names <- names(tag_funs)

  s <- rlang::new_environment()

  for (tag_name in tag_names) {
    s[[tag_name]] <- local({
      tn <- tag_name
      function(...) {
        processed_args <- process_sherpa_attrs(...)
        do.call(shiny::tags[[tn]], processed_args)
      }
    })
  }

  return(s)
}


#' @rdname tag-proxy
#' @export
s <- create_tag_proxy()


#' Sherpa Attribute Operator
#'
#' Appends Sherpa attributes to a tag without needing the !!! operator.
#'
#' @param tag A shiny tag
#' @param ... Sherpa attributes (e.g., x_data(), x_cloak())
#' @export
#' @aliases sherpa_operator
#' @rdname sherpa_operator
`%s%` <- function(tag, ...) {
  if (!inherits(tag, "shiny.tag")) {
    stop("The left side of %s% must be a shiny tag.")
  }

  attrs <- process_sherpa_attrs(...)
  do.call(shiny::tagAppendAttributes, c(list(tag), attrs))
}

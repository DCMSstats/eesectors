#' @title Raise warning when assertr checks fail
#'
#' @description \code{raise_issue} replaces the default function
#'   \code{assert_stop} which is triggered when an assertion fails. \code{y},
#'   relative to \code{x}
#'
#' @details The default behaviour of \code{assertr] of generating an error when
#'   assertions are failed could be problematic if the assertion fails for a
#'   legitimate reason. This would require an analyst to be able to re-engineer
#'   the workings of the function to fix the problem
#'
#'   It is safer to issue a \code{warning} instead, which alerts the user to an
#'   issue, but does not prevent the program from running.
#'
#' @param err_str Error string arising from an \code{assert::insist_}.
#'
#' @return Warning.

raise_issue <- function(err_str){

  warning(err_str)
}


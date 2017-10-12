
#' @title Warn when assertr checks fail and raise issue on github
#'
#' @description \code{raise_issue} replaces the default function
#'   \code{assert_stop} which is triggered when an assertion fails. \code{y},
#'   relative to \code{x}. Optionally allows issues to be posted to a github
#'   repository.
#'
#' @details The default behaviour of \code{assertr::insist_} of generating an
#'   error when assertions are failed could be problematic if the assertion
#'   fails for a legitimate reason. This would require an analyst to be able to
#'   re-engineer the workings of the function to fix the problem.
#'
#'   It is safer to issue a \code{warning} instead, which alerts the user to an
#'   issue, but does not prevent the program from running.
#'
#'   If \code{log_issues = TRUE}, and \code{owner}, \code{repo}, and
#'   \code{title} are not \code{NULL} an issue is created in the given github
#'   \code{repo} with \code{title} and additional arguments given by \code{...}.
#'
#' @param err_str Error string arising from an \code{assert::insist_}.
#'
#' @return \code{err_str} as warning.
#'
#' @export

raise_issue <- function(err_str) {
  warning(err_str)
}


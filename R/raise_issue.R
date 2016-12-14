
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
#' @param log_issues Allow logging of issues to github? Defaults to
#'   \code{FALSE}.
#' @param owner github username of the owner of the repository where issues will
#'   be raised following each test fail. If not specified, this will be set by
#'   the environmental variable 'LOG_OWNER'.
#' @param repo github repository where issues will be raised following each test
#'   fail. If not specified, this will be set by the environmental variable
#'   'LOG_REPO'.
#' @param title Title of the issue to be raised in the \code{owner}'s github
#'   repository \code{repo}. Defaults to \code{'Data quality issue'} but in
#'   future should be set dynamically depending on the issue.
#' @param body Body test of the issue to be raised in the \code{owner}'s github
#'   repository \code{repo}.
#'
#' @return \code{err_str} as warning.
#'
#' @export

raise_issue <- function(
  err_str,
  log_issues = FALSE,
  owner = NULL,
  repo = NULL,
  title = 'Data quality issue',
  body = NULL
  ){

  if (is.null(owner)) owner <- Sys.getenv('LOG_OWNER')
  if (is.null(repo)) repo <- Sys.getenv('LOG_REPO')

  tryCatch(
     expr = {

       if (log_issues) {
      gh::gh(
        "POST /repos/:owner/:repo/issues",
        owner = owner,
        repo = repo,
        title = title,
        body = err_str
      )
       }
    },
    warning = function() {

      w <- warnings()
      warning('Warning produced when running raise_issue():', w)

    },
    error = function(e)  {

      stop('Error produced running raise_issue():', e)

    },
    finally = {}
  )

  warning(err_str)
}


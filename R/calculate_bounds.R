#' @title Helper function to calculate upper and lower bounds
#'
#' @description Calculates the upper bounds of acceptable values based on the
#'   \code{median(x) + mad(x) * tol} where \code{is.integer(tol) == TRUE} and
#'   the obverse lower bound, and presents the upper and lower bounds in a
#'   dataframe with the variable of interest.
#'
#' @details Provides the basis of tests for the most recently calculated values
#'   of Gross Value Added (GVA), exports, etc. The rationale is that this year's
#'   statistics should be fairly similar to last year's, and we can use
#'   statistical tests to identify possibly erroneous values.
#'
#'   Statistical tests can be as complicated as we desire, but in the present
#'   version the test is a simple outlier detection based on identifying values
#'   that are more than \code{x} times the median absolute deviation
#'   (\code{mad()}), where \code{x} is defined by the \code{tol()} argument.
#'   This defaults to three, but can be adjusted for more or less stringent
#'   outlier tests.
#'
#'   Summary statistics like \code{mean} and \code{mad} are computed on the data
#'   prior to \code{test_year}, equivalent to: \code{df[df$year < test_year,]}.
#'
#' @param df Dataframe to test.
#' @param measure Quoted variable name of interest from \code{df}.
#' @param test_year Year of interest to test.
#' @param tol Round output to this many digits.
#'
#' @return Returns the percentage difference of \code{y} relative to \code{x}.
#'
#' @references Leys et al. (2013), 'Detecting outliers: Do not use standard
#'   deviation around the mean, use absolute deviation around the median',
#'   Journal of Experimental Social Psychology. 49 (4), pp. 764 - 766.
#'   http://dx.doi.org/10.1016/j.jesp.2013.03.013
#'
#' @importFrom lazyeval interp

calculate_bounds <- function(df, measure = NULL, test_year = NULL, tol = 3) {

  # Deal with the default arguments:
  # measure

  measure <- if (is.null(measure)) {

    measure <- colnames(df)[!colnames(df) %in% c('year','sector')]

  } else if (is.character(measure) & measure %in% colnames(df)) {

    measure

  } else stop('measure must either be NULL or a column name contained within colnames(df).')


  # test_year

  test_year <- if (is.null(test_year)) {

    max(df$year)

  } else if (test_year %in% unique(df$year)) {

    test_year

  } else stop('test_year must either be NULL or an integer contained within unique(df$year).')


  out <- tryCatch(
    expr = {

      # Calculate the median and mad for all values prior to the maximum (or
      # specified) year

      df_test <- dplyr::filter_(df, ~year < test_year)
      df_test <- dplyr::group_by_(df_test, ~sector)
      df_test <- dplyr::summarise_(
        df_test,
        median = lazyeval::interp(~median(var), var = as.name(measure)),
        mad = lazyeval::interp(~mad(var), var = as.name(measure))
      )

      # Calculate the upper and lower bounds based on the median and mad

      df_test <- dplyr::transmute_(
        df_test,
        ~sector,
        upper_bound = ~median + (tol * mad),
        lower_bound = ~median - (tol * mad)
      )

      # Join the upper and lower bounds with values from the most recent year

      df_new <- dplyr::filter_(df, ~year == test_year)
      df_new <- suppressMessages(dplyr::left_join(df_new, df_test))

      return(df_new)
    },
    warning = function() {

      w <- warnings()
      warning('Warning produced calculate_bounds():', w)

    },
    error = function(e)  {

      stop('Error produced running calculate_bounds():', e)

    },
    finally = {}
  )
}

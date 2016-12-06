#' @title long data class
#'
#' @description \code{long_data} is the class used for the creation of tables
#'   3.1, 4.1, 4.5, and 5.1 of the DCMS Sectors Economic Estimate
#'   (\url{https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/544103/DCMS_Sectors_Economic_Estimates_-_August_2016.pdf}).
#'
#' @details The \code{long_data} class expects a \code{data.frame} with three
#'   columns: sector, year, and measure, where measure is one of GVA, exports,
#'   or enterprises. The \code{data.frame} should include historical data, which
#'   is used for checks on the quality of this year\'s data, and for producing
#'   tables and plots.
#'
#'   Once inititated, the class has five slots: \code{df}: the basic
#'   \code{data.frame}, \code{colnames}: a character vector containing the
#'   column names from the \code{df}, \code{type}: a character vector of
#'   \code{length(type) == 1} describing the type of data (\"GVA\", \"exports\",
#'   or \"enterprises\") imputed from column names, \code{sector_levels}: a
#'   factor vector containing levels of \code{df$sector} of the factor sector,
#'   \code{years}: an integer vector containing \code{unique(df$year)}.
#'
#' @param x Input dataframe, see details.
#'
#' @return If the class is instantiated correctly, nothing is returned.
#'
#' @examples
#'
#' library(EESectors)
#'
#' GVA <- long_data(GVA_by_sector_2016)
#'
#' @importFrom lazyeval interp
#' @export


long_data <- function(x) {

  message('Initiating long_data class.\n\nExpects a data.frame with three columns: sector, year, and measure, where measure is one of
GVA, exports, or enterprises. The data.frame should include historical data, which is used for checks on the quality of
this year\'s data, and for producing tables and plots. More information on the format expected by this class is given by
?long_data().')

  # Integrity checks on incoming long table

  message('\n*** Running integrity checks on input dataframe:')

  message('\nChecking input is properly formatted...')

  if (!is.data.frame(x)) stop("x must be a data.frame")

  if (length(colnames(x)) != 3) stop("x must have three columns: sector, year, and one of GVA, export, or x")

  if (!'year' %in% colnames(x)) stop("x must contain year column")

  if (!'sector' %in% colnames(x)) stop("x must contain sector column")

  if (anyNA(x)) stop("x cannot contain any missing values")

  if (nrow(x) != length(unique(x$sector)) * length(unique(x$year))) {

    warning("x does not appear to be well formed. nrow(x) should equal
length(unique(x$sector)) * length(unique(x$year)). Check the of x.")
  }

  message('...passed')

  message('\nChecking current year\'s values against previous years. These tests are implemented
in the function calculate_bounds(). See ?calculate_bounds() for more information...')

  test_df <- calculate_bounds(x, colnames(x)[!colnames(x) %in% c('year','sector')], tol = 3)

  if (any(test_df$GVA > test_df$upper_bound) | any(test_df$GVA < test_df$lower_bound)) {

    warning('x failed statistical testing based on')

  } else message('...passed')

  structure(
  list(
      df = x,
      colnames = colnames(x),
      type = colnames(x)[!colnames(x) %in% c('year','sector')],
      sector_levels = unique(x$sector),
      years = unique(x$year)
    ),
    class = "long_data")
}

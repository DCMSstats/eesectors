#' @title long data class
#'
#' @description \code{long_data} is the class used for the creation of tables
#'   3.1, 4.1, 4.5, and 5.1 of the DCMS Sectors Economic Estimate
#'   (\url{https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/544103/DCMS_Sectors_Economic_Estimates_-_August_2016.pdf}).
#'
#'
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
#' @param log_issues should issues with the data quality be logged to github?
#'   See \code{?raise_issue()} for additional details.
#'
#' @return If the class is instantiated correctly, nothing is returned.
#'
#' @examples
#'
#' library(eesectors)
#'
#' GVA <- long_data(GVA_by_sector_2016)
#'
#' @export


long_data <- function(x, log_issues = FALSE) {

  message('Initiating long_data class.
\n\nExpects a data.frame with three columns: sector, year, and measure, where
measure is one of GVA, exports, or enterprises. The data.frame should include
historical data, which is used for checks on the quality of this year\'s data,
and for producing tables and plots. More information on the format expected by
this class is given by ?long_data().')

  # Integrity checks on incoming long table ----

  # Check the structure of the data is as expected: data.frame containing no
  # missing values and three columns, containing sector, year, and one
  # additional column.

  message('\n*** Running integrity checks on input dataframe (x):')
  message('\nChecking input is properly formatted...')
  message('Checking x is a data.frame...')
  if (!is.data.frame(x)) stop("x must be a data.frame")

  message('Checking x has correct columns...')
  if (length(colnames(x)) != 3) stop("x must have three columns: sector, year, and one of GVA, export, or x")

  message('Checking x contains a year column...')
  if (!'year' %in% colnames(x)) stop("x must contain year column")

  message('Checking x contains a sector column...')
  if (!'sector' %in% colnames(x)) stop("x must contain sector column")

  message('Checking x does not contain missing values...')
  if (anyNA(x)) stop("x cannot contain any missing values")

  message('Checking for the correct number of rows...')
  if (nrow(x) != length(unique(x$sector)) * length(unique(x$year))) {

    warning("x does not appear to be well formed. nrow(x) should equal
length(unique(x$sector)) * length(unique(x$year)). Check the of x.")
  }

  message('...passed')

  # User assertr to run statistical tests on the data itself ----

  message('\n***Running statistical checks on input dataframe (x)...\n
  These tests are implemented using the package assertr see:
  https://cran.r-project.org/web/packages/assertr for more details.')

  # Extract third column name

  value <- colnames(x)[(!colnames(x) %in% c('sector','year'))]

  # Check snsible range for year

  message('Checking years in a sensible range (2000:2020)...')

  assertr::assert_(x, assertr::in_set(2000:2020), ~year)

  # Check that the correct levels are in sector

  message('Checking sectors are correct...')

  # Save sectors name lookup for use later

  sectors_set <- c(
    "creative"    = "Creative Industries",
    "culture"    = "Cultural Sector",
    "digital"     = "Digital Sector",
    "gambling"    = "Gambling",
    "sport"       = "Sport",
    "telecoms"    = "Telecoms",
    "tourism"     = "Tourism",
    "all_dcms"    = "All DCMS sectors",
    "perc_of_UK"  = "% of UK GVA",
    "UK"          = "UK"
  )

  assertr::assert_(x, assertr::in_set(names(sectors_set)), ~sector, error_fun = raise_issue)

  # Check for outliers ----

  # Check for simple outliers in the value column (GVA, exports, enterprises)
  # for each sector, over the entire timeseries. Outliers are detected using
  # median +- 3 * median absolute deviation, implemented in the
  # assertr::within_n_mads() function.

  message('Checking for outliers (x_i > median(x) + 3 * mad(x)) in each sector timeseries...')

  # Create a list split by series containing a df in each

  series_split <- split(x, x$sector)

  # Apply to each df in the list

  lapply(
    X = series_split,
    FUN = function(x) {
      message('Checking sector timeseries: ', unique(x[['sector']]))
      assertr::insist_(
        x,
        assertr::within_n_mads(3),
        lazyeval::interp(~value, value = as.name(value)),
        error_fun = raise_issue)
    }
  )

  message('...passed')

  # Check for outliers using mahalanobis ----

  # This test also looks for outliers, by considering the relationship between
  # the variable year and the value variable. It measures the mahalabois
  # distance, which is similar to the euclidean norm, and then looks for
  # ourliers in this new vector of norms. Any value with a distance too great is
  # flagged as an outlier.

  message('Checking for outliers on a row by row basis using mahalanobis distance...')

  lapply(
    X = series_split,
    FUN = function(x) {

      # Note that this test will fail on GVA_by_sector_2016 if x < 6 for
      # within_n_mads(x)

      message('Checking sector timeseries: ', unique(x[['sector']]))
      assertr::insist_rows(
        x,
        assertr::maha_dist,
        assertr::within_n_mads(6),
        dplyr::everything(),
        error_fun = raise_issue
      )
    }
  )

  message('...passed')

  # Define the class here ----

  structure(
    list(
      df = x,
      colnames = colnames(x),
      type = colnames(x)[!colnames(x) %in% c('year','sector')],
      sector_levels = levels(x$sector),
      sectors_set = sectors_set,
      years = unique(x$year)
    ),
    class = "long_data")
}

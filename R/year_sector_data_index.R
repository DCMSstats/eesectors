#' @title long data class
#'
#' @description \code{year_sector_data} is the class used for the creation of tables
#'   3.1, 4.1, 4.5, and 5.1 of the DCMS Sectors Economic Estimate
#'   (\url{https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/544103/DCMS_Sectors_Economic_Estimates_-_August_2016.pdf}).
#'
#'
#'
#' @details The \code{year_sector_data} class expects a \code{data.frame} with three
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
#' @param log_level The severity level at which log messages are written from
#' least to most serious: TRACE, DEBUG, INFO, WARN, ERROR, FATAL. Default is
#' level is INFO. See \code{?flog.threshold()} for additional details.
#' @param log_appender Defaults to write the log to "console", alternatively you
#' can provide a character string to specify a filename to also write to. See
#' for additional details \code{?futile.logger::appender.tee()}.
#' @param log_issues should issues with the data quality be logged to github?
#'   See \code{?raise_issue()} for additional details.
#'
#' @return If the class is instantiated correctly, nothing is returned.
#'
#' @examples
#'
#' library(eesectors)
#'
#' GVA <- year_sector_data(GVA_by_sector_2016)
#'
#' @export


year_sector_data_index <- function(x, log_level = futile.logger::WARN,
                             log_appender = "console",
                             log_issues = FALSE) {

  # Set logger severity threshold, defaults to
  # high level use (only flags warnings and errors)
  # Set log_level argument to futile.logger::TRACE for full info
  futile.logger::flog.threshold(log_level)

  # Set where to write the log to
  if (log_appender != "console")
  {
    # if not console then to a file called...
    futile.logger::flog.appender(futile.logger::appender.file(log_appender))
  }

  # Checks
  futile.logger::flog.info('Initiating year_sector_data class.
\n\nExpects a data.frame with three columns: sector, year, and measure, where
measure is one of GVA, exports, or enterprises. The data.frame should include
historical data, which is used for checks on the quality of this year\'s data,
and for producing tables and plots. More information on the format expected by
this class is given by ?year_sector_data().')

  # Integrity checks on incoming data ----

  # Check the structure of the data is as expected: data.frame containing no
  # missing values and three columns, containing sector, year, and one
  # additional column.

  futile.logger::flog.info('\n*** Running integrity checks on input dataframe (x):')
  futile.logger::flog.debug('\nChecking input is properly formatted...')

  futile.logger::flog.debug('Checking x is a data.frame...')
  if (!is.data.frame(x))
    {
    futile.logger::flog.error("x must be a data.frame",
                              x, capture = TRUE)
    }

  futile.logger::flog.debug('Checking x has correct columns...')
  if (length(colnames(x)) != 3)
    {
    futile.logger::flog.error("x must have three columns: sector, year, and one of GVA, export, or x")
    }

  futile.logger::flog.debug('Checking x contains a year column...')
  if (!'year' %in% colnames(x)) stop("x must contain year column")

  futile.logger::flog.debug('Checking x contains a sector column...')
  if (!'sector' %in% colnames(x)) stop("x must contain sector column")

  futile.logger::flog.debug('Checking x does not contain missing values...')
  if (anyNA(x)) stop("x cannot contain any missing values")

  futile.logger::flog.debug('Checking for the correct number of rows...')
  if (nrow(x) != length(unique(x$sector)) * length(unique(x$year))) {
    futile.logger::flog.warn("x does not appear to be well formed. nrow(x) should equal
                             length(unique(x$sector)) * length(unique(x$year)). Check the of x.")
  }



  futile.logger::flog.info('...passed')

  # User assertr to run statistical tests on the data itself ----

  futile.logger::flog.info("\n***Running statistical checks on input dataframe (x)")

  futile.logger::flog.trace("These tests are implemented using the package assertr see:
  https://cran.r-project.org/web/packages/assertr for more details.")

  # Extract third column name

  value <- colnames(x)[(!colnames(x) %in% c('sector','year'))]

  # Check snsible range for year

  futile.logger::flog.debug('Checking years in a sensible range (2000:2020)...')

  assertr::assert_(x, assertr::in_set(2000:2020), ~year)

  # Check that the correct levels are in sector

  futile.logger::flog.debug('Checking sectors are correct...')

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

  futile.logger::flog.debug('Checking for outliers (x_i > median(x) + 3 * mad(x)) in each sector timeseries...')

  # Create a list split by series containing a df in each

  series_split <- split(x, x$sector)

  # Apply to each df in the list

  lapply(
    X = series_split,
    FUN = function(x) {
      futile.logger::flog.trace("Checking sector timeseries: %s",
                                as.character(unique(x[['sector']])),
                                capture = FALSE)
      assertr::insist_(
        x,
        assertr::within_n_mads(3),
        lazyeval::interp(~value, value = as.name(value)),
        error_fun = raise_issue)
    }
  )

  futile.logger::flog.info('...passed')

  # Check for outliers using mahalanobis ----

  # This test also looks for outliers, by considering the relationship between
  # the variable year and the value variable. It measures the mahalabois
  # distance, which is similar to the euclidean norm, and then looks for
  # ourliers in this new vector of norms. Any value with a distance too great is
  # flagged as an outlier.

  futile.logger::flog.debug('Checking for outliers on a row by row basis using mahalanobis distance...')

  lapply(
    X = series_split,
    FUN = maha_check
  )

  futile.logger::flog.debug('...passed')

  ### ISSUE - these might be "changing the world" for the user unexpectedly!

  # Reset threshold to package default
  futile.logger::flog.threshold(futile.logger::INFO)
  # Reset so that log is appended to console (the package default)
  futile.logger::flog.appender(futile.logger::appender.console())

  # Message required to pass a test
  message("Checks completed successfully:
object of 'year_sector_data' class produced!")

  # add index for value column
  x <- x %>%
    # replaces values in sector with lookup in year_sector_data
    mutate(sector = factor(unname(sectors_set[as.character(sector)]))) %>%

    # calculate the index (index_year=100) variable
    group_by(sector) %>%
    mutate(indexGVA = GVA/max(ifelse(year == min(x$year), GVA, 0)) * 100)

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
    class = "year_sector_data_index")
}

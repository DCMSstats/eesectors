#' @title add index column
#'
#' @description
#'   NOTE: THIS FUNCTION RELIES ON DATA WHICH ARE CLASSIFIED AS
#'   OFFICIAL-SENSITIVE. THE OUTPUT OF THIS FUNCTION IS AGGREGATED, AND
#'   PUBLICALLY AVAILABLE IN THE FINAL STATISTICAL RELEASE, HOWEVER CARE MUST BE
#'   EXERCISED WHEN CREATING A PIPELINE INCLUDING THIS FUNCTION. IT IS HIGHLY
#'   ADVISEABLE TO ENSURE THAT THE DATA WHICH ARE CREATED BY THE \code{extract_}
#'   FUNCTIONS ARE NOT STORED IN A FOLDER WHICH IS A GITHUB REPOSITORY TO
#'   MITIGATE AGAINST ACCIDENTAL COMMITTING OF OFFICIAL DATA TO GITHUB. TOOLS TO
#'   FURTHER HELP MITIGATE THIS RISK ARE AVAILABLE AT
#'   https://github.com/ukgovdatascience/dotfiles.
#'
#' @details Uses \code{val} and year columns to produce new column,
#' containing an index of \code{val} starting at the year specified by
#' \code{index_year}. The column is named index, suffixed by the name of
#' \code{val}. Returns x$df with additional column.
#'
#' @param x Year_sector_data_object
#' @param val Column in x$df containing values to be indexed
#' @param index_year Year to start indexing. uses min x$years by default
#' @param log_level The severity level at which log messages are written from
#' least to most serious: TRACE, DEBUG, INFO, WARN, ERROR, FATAL. Default is
#' level is INFO. See \code{?flog.threshold()} for additional details.
#' @param log_appender Defaults to write the log to "console", alternatively you
#' can provide a character string to specify a filename to also write to. See
#' for additional details \code{?futile.logger::appender.file()}.
#'
#' @export

add_index <- function(x, val, index_year, log_level, log_appender) UseMethod("add_index")

add_index.default <- function(x, val, index_year, log_level, log_appender)
  stop("parameter x must be an object with class year_sector_data")

add_index.year_sector_data <- function(
  x = NULL,
  val = NULL,
  index_year = NULL,
  log_level = futile.logger::INFO,
  log_appender = "console") {

# set up logging
futile.logger::flog.threshold(log_level)
if (log_appender != "console")
  futile.logger::flog.appender(futile.logger::appender.file(log_appender))


df <- x$df %>%
  # replaces values in sector with lookup in year_sector_data
  mutate(sector = factor(unname(x$sectors_set[as.character(sector)]))) %>%

  # calculate the index (index_year=100) variable
  group_by(sector) %>%
  mutate(indexGVA = GVA/max(ifelse(year == min(x$years), GVA, 0)) * 100)


# clear up logging side effects
futile.logger::flog.threshold(futile.logger::INFO)
futile.logger::flog.appender(futile.logger::appender.console())

return(df)
}

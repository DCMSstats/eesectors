#' @title extract ABS data from ONS working file spreadsheet
#'
#' @description The data which underlies the Economic Sectors for DCMS sectors
#'   data is typically provided to DCMS as a spreadsheet from the Office for
#'   National Statistics. This function extracts the ABS data from that
#'   spreadsheet.
#'
#' @details The best way to understand what happens when you run this function
#'   is to look at the source code, which is available at
#'   \url{https://github.com/ukgovdatascience/eesectors/blob/master/R/}. The
#'   code is relatively transparent and well documented. I give a brief
#'   explanation of what the function does here:
#'
#'   1. The function calls \code{readxl::read_excel} to load the appropriate
#'   page from the underlying spreadsheet.
#'
#'   2. In the 2016 version of the working file spreadhseet, there were a number
#'   of replicated columns. These are removed, however it is at present a
#'   relatively dumb exercise. The function simply looks for columns with teh
#'   same name, and retains only the first one.
#'
#'   3. The column names are cleaned to make selection of variables easier using
#'   \code{make.names}.
#'
#'   4. The data are pivoted into long form using \code{tidyr::gather_}. This
#'   converts the data from a wide dataframe with year as column headers, into a
#'   long dataframe with year included in a year column. This makes the data
#'   much easier to subset.
#'
#'   5. All the abs values are combined into a column called \code{abs}. In the
#'   2016 spreadsheet there were a number of full stops (\code{.}) in the
#'   \code{abs} column, which will be coerced to \code{NA} when the the column
#'   is converted to numeric using \code{as.numeric} (the next step). The
#'   internal function \code{eesectors::integrity_check} runs a quick check to
#'   make sure that the only NAs creeping into the \code{abs} column are from
#'   full stops in the original data. The full stops are then converted to
#'   zeros.
#'
#'   6. The internal function \code{eesectors::clean_sic} is run on the
#'   \code{DOMVAL} column to ensure that all 3 and 4 digit SIC codes are
#'   formatted properly.
#'
#'   7. The data are written out to disk using the provided \code{output_path}
#'   and the filename, which is fixed as \code{OFFICIAL_ABS.Rds}. The success of
#'   this procedure is reported, and a file size given if successful.
#'
#' @param x Location of the input spreadsheet file. Named something like
#'   "working_file_dcms_VXX.xlsm".
#' @param sheet_name The name of the spreadsheet in which the data are stored.
#'   Defaults to \code{New ABS Data}.
#' @param output_path The directory in which the output data is to be stored.
#'   Defaults to \code{.}.
#'
#' @return The function returns \code{NULL}, but saves the extracted dataset to
#'   \code{file.path(output_path, 'OFFICIAL_ABS.Rds')}. This is an R data
#'   object, which retains the column types which would be lost if converted to
#'   a flat format like CSV.
#'
#' @examples
#'
#' \dontrun{
#' library(eesectors)
#' extract_ABS_data(
#' x = 'OFFICIAL_working_file_dcms_V13.xlsm',
#' sheet_name = 'New ABS Data',
#' output_path = '../OFFICIAL/'
#' )
#' }
#'
#' @export

extract_GVA_data <- function(
  x,
  sheet_name = 'New ABS Data',
  output_path = '.'
) {

  # Use readxl to load the data directly from the spreadsheet.

  x <- readxl::read_excel(path = x, sheet = sheet_name)

  # Check for and remove duplicated columns - in the 2016 publication, the 2013
  # and 2014 columns were repeated. Note that this only assumes that the
  # replication is complete. If two columns are present with the same name, but
  # different content, this will simply choose the first column.

  x <- x[, !duplicated(colnames(x))]

  # Create sensible column names, to make selection easier

  colnames(x) <- make.names(colnames(x))

  # In case there are othe extraneos columns, such as ``, select out only the
  # columns that we are interested in.

  x <- dplyr::select_(x, 'DOMVAL', 'X2008', 'X2009', 'X2010', 'X2011', 'X2012', 'X2013', 'X2014')

  # Pivot the data into long form. In doing so, I discovered that some of the
  # values in the original data were not being cleanly converted into an integer.
  # Here I check why this is the case. This seems to be due to the presence of
  # full stops in the data, which might be suppressed?, or look like they should
  # be zeros. The function integrity_check is designed to check that the values
  # that resolve to NA should really be NAs.

  # First convert to long form

  x <- tidyr::gather_(
    data = x,
    key = 'year',
    value = 'abs',
    gather_cols = c('X2008', 'X2009', 'X2010', 'X2011', 'X2012', 'X2013', 'X2014')
  )

  # Then strip out the X in the year column, and conver to integer

  x$year <- gsub('X','',x$year)
  x$year <- as.integer(x$year)

  # Run the integrity check function to check for conversion issues.

  check_na <- eesectors::integrity_check(x$abs)

  # Check that there are no unexpected failures to convert numbers from character
  # to numeric

  testthat::expect_is(x$abs[check_na], 'character')
  testthat::expect_equal(unique(x$abs[check_na]), '.')

  # Lots of full stops... After examining the data, it looks like these values
  # should be zeros. But will chase up with DCMS. Convert them to zeros here:

  x <- dplyr::mutate_(
    x,
    abs = ~ifelse(check_na, 0, abs),
    abs = ~as.numeric(abs)
  )

  # Now check again that they were successfully removed.

  testthat::expect_is(x$abs[check_na], 'numeric')
  testthat::expect_equal(sum(x$abs[check_na]), 0)

  # Yes... they have been converted to zeros as expected

  # Finally, clean up the sic code by adding a full stop to cases when it is a
  # three or four character codes.

  x$DOMVAL <- eesectors::clean_sic(x$DOMVAL)

  # Save the data out as an R serialisation object

  full_path <- file.path(output_path, 'OFFICIAL_ABS.Rds')

  save_rds(x, full_path = full_path)

  message(
    '################################# WARNING ############################
    The data produced by this function may contain OFFICIAL information.
    Ensure that the data are not committed to a github repository.
    Tools to prevent the accidental committing of data are available at:
    https://github.com/ukgovdatascience/dotfiles.'
    )

}

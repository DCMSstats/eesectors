#' @title extract SIC 91 Sales Data from ONS working file spreadsheet
#'
#' @description The data which underlies the Economic Sectors for DCMS sectors
#'   data is typically provided to DCMS as a spreadsheet from the Office for
#'   National Statistics. This function extracts the SIC Sales Data from that
#'   spreadsheet, and saves it to .Rds format. These data are used in place of
#'   the usual GVA values. An explanation of why can be found in the methodology
#'   note that accompanies the statistical first release
#'   (\url{https://www.gov.uk/government/publications/dcms-sectors-economic-estimates-methodology}).
#'
#'
#'   IT IS HIGHLY ADVISEABLE TO ENSURE THAT THE DATA WHICH ARE CREATED BY THIS
#'   FUNCTION ARE NOT STORED IN A FOLDER WHICH IS A GITHUB REPOSITORY TO
#'   MITIGATE AGAINST ACCIDENTAL COMMITTING OF OFFICIAL DATA TO GITHUB. TOOLS TO
#'   FURTHER HELP MITIGATE THIS RISK ARE AVAILABLE AT
#'   https://github.com/ukgovdatascience/dotfiles.
#'
#' @details The best way to understand what happens when you run this function
#'   is to look at the source code, which is available at
#'   \url{https://github.com/ukgovdatascience/eesectors/blob/master/R/}. The
#'   code is relatively transparent and well documented. A brief explanation of
#'   what the function does here:
#'
#'   1. The function calls \code{readxl::read_excel} to load the appropriate
#'   page from the underlying spreadsheet.
#'
#'   2. Columns of interest are subset using \code{x[, c('SIC', 'year', 'ABS')]}
#'
#'   3. Empty rows (containing all \code{NA}s) are removed.
#'
#'   4. The data are saved out to an R serialisation object
#'   \code{OFFICIAL_SIC91.Rds} in the specified folder.
#'
#' @param x Location of the input spreadsheet file. Named something like
#'   "working_file_dcms_VXX.xlsm".
#' @param sheet_name The name of the spreadsheet in which the data are stored.
#'   Defaults to \code{New ABS Data}.
#' @param col_names character vector used to rename the column names from the
#'   imported spreadsheet. Defaults to
#'   \code{c('year','ABS','total','perc','overlap')}.
#' @param ... additional arguments to be passed to \code{readxl::read_excel}.
#'
#' @return The function returns nothing, but saves the extracted dataset to
#'   \code{file.path(output_path, 'OFFICIAL_ABS.Rds')}. This is an R data
#'   object, which retains the column types which would be lost if converted to
#'   a flat format like CSV.
#'
#' @examples
#'
#' \dontrun{
#' library(eesectors)
#' extract_toursim_data(
#' x = 'OFFICIAL_working_file_dcms_V13.xlsm',
#' sheet_name = 'Tourism'
#' )
#' }
#'
#' @export

extract_SIC91_data <- function(
  x,
  sheet_name = 'SIC 91 Sales Data',
  col_names = c('SIC','description','year','ABS','blank','code'),
  ...
) {

  # Load the data using readr. Note that additional arguments (e.g. skip, and
  # colnames) can be passed to read_excel using the ... operator

  x <- readxl::read_excel(path = x, sheet = sheet_name, col_names = col_names, ...)

  # Extract columns of interest

  x <- x[, c('SIC', 'year', 'ABS')]

  # Drop rows that are completely NA from the bottom of the dataset/

  mask <- !(is.na(x$SIC) & is.na(x$year) & is.na(x$ABS))

  x <- x[mask, ]

  message(
    '################################# WARNING #################################
    The data produced by this function may contain OFFICIAL information.
    Ensure that the data are not committed to a github repository.
    Tools to prevent the accidental committing of data are available at:
    https://github.com/ukgovdatascience/dotfiles. Pay special attention
    to .Rdata files, and .Rhistory files produced by Rstudio. Best practice
    is to disable the creation of such files.'
  )

  structure(
    x,
    class = c("SIC91", class(x))
  )

}

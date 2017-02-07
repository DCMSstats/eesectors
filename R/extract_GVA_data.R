#' @title extract GVA data from ONS working file spreadsheet
#'
#' @description The data which underlies the Economic Sectors for DCMS sectors
#'   data is typically provided to DCMS as a spreadsheet from the Office for
#'   National Statistics. This function extracts the GVA data from that
#'   spreadsheet, and saves it to .Rds format. These data are spread over
#'   multiple worksheets (usually named \code{2010 Use}, etc), so this function
#'   iteratres over a user supplied (or default) list of worksheets to extract
#'   the data.
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
#'   1. The function calls \code{readxl::read_excel} to load the first worksheet
#'   given by the argument \code{sheet_range}, using the defaults this will be
#'   \code{1997 Use}.
#'
#'   2. The rows denoted by \code{header_rows} are extracted into a new
#'   dataframe, and the SIC codes formatted to prepend zeros onto values which
#'   are numeric, and have a character length of one (integers between 0 and 9).
#'
#'   3. The SIC code descriptions are then cleaned to make them a bit more
#'   friendly to work with.
#'
#'   4. The rows that we are interested in are subset using the \code{slice}
#'   argument. It may be necessary to look into the target spreadsheet to
#'   establish which rows are of interest. Note that these will appear as
#'   columns in the spreadsheet, and are transposed into rows in the above step
#'   2.
#'
#'   5. The \code{purrr::map_df} function is run on the \code{sheet_range}
#'   vector. This creates a master dataframe containing teh GVA values from each
#'   of the worksheets. If default values are used, this will be sheets
#'   \code{1997 Use} through to \code{2015 Use}.
#'
#'   6. The \code{.id} column is renamed to year for each of the corresponding
#'   worksheets from which data have been extracted.
#'
#'   7. The SIC codes extracted into \code{y} in previous steps are now applied
#'   to the data, matching up SIC codes with the relevant GVA values.
#'
#'   8. Finally \code{tidyr::gather} is run to collect the data into a long
#'   dataframe to make subsetting easier. The data are then saved out to a file
#'   based on whether \code{test = TRUE}. Note that the default behaviour is to
#'   prepend OFFICIAL onto the filename to prevent it from accidentally being
#'   committed to a public repository. Note that if you use appropriate tools
#'   (\url{https://github.com/ukgovdatascience/dotfiles}), checking for OFFICIAl
#'   files becomes an automated process.
#'
#' @param x Location of the input spreadsheet file. Named something like
#'   "working_file_dcms_VXX.xlsm".
#' @param sheet_range The range of sheets over which to iterate and extract GVA
#'   data. Defaults to \code{paste(paste(1997:2015), 'Use')}.
#' @param col_names Passes to \code{readxl::read_excel}. In most cases the
#'   default \code{FALSE} will be appropriate, unless major changes occur to the
#'   udnerlying spreadsheet.
#' @param header_rows The rows in the original spreadsheet from which the
#'   headers (SIC and description) will be taken. Defaults to \code{8:9}.
#' @param slice The rows of interest as desribed below in 4. Defaults to
#'   \code{3:122} which captures all the SIC codes for which GVA data are
#'   supplied in the underlying spreadsheets.
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
#' extract_GVA_data(
#' x = 'OFFICIAL_working_file_dcms_V13.xlsm'
#' )
#' }
#'
#' @export

extract_GVA_data <- function(
  x,
  sheet_range = paste(paste(1997:2015), 'Use'),
  col_names = FALSE,
  header_rows = 8:9,
  slice = 3:122
) {

  # First extract the header variables (y for brevity) from the last sheet in
  # the range

  y <- readxl::read_excel(
    path = x,
    col_names = FALSE,
    sheet = sheet_range[[length(sheet_range)]]
  )

  # Since the location of the headers can shift, allow this to be set with
  # header_rows.

  y <- data.frame(
    SIC = as.character(y[header_rows[[1]],]),
    description = as.character(y[header_rows[[2]],]),
    stringsAsFactors = FALSE
  )

  # Prepend single integer values with 0 to match the usual SIC code format.

  y$SIC <- zero_prepend(y$SIC)

  # Tidy up the description column by converting to lower and stripping whitespace,
  # etc.

  y[['description']] <- tolower(y[['description']])
  y[['description']] <- gsub('\\s\\s+?', '', y[['description']])
  y[['description']] <- gsub('\\ \\ +?|\\\n', ' ', y[['description']])
  y[['description']] <- gsub('\\,', '', y[['description']])
  y[['SIC']] <- as.character(y[['SIC']])

  # If any SICs are missing use the description instead

  y[['SIC']] <- ifelse(is.na(y[['SIC']]), y[['description']], y[['SIC']])

  # Drop any NA SICs

  y <- y[which(!is.na(y[['SIC']])), ]

  # Subset out the rows we are interested in.

  y <- y[slice,]

  # Now cycle over sheet_range, extracting the rows we are interested in.

  x <- purrr::map_df(
    .x = sheet_range,
    .f = function(sheet) {readxl::read_excel(x, sheet = sheet, col_names = FALSE)},
    .id = 'year'
  )

  # Extract only the rows that contain GVA(P) in the second column.

  x <- x[which((x[,2] == 'GVA(P)')),]

  # Convert the integer into sheet names

  x[['year']] <- sheet_range[as.integer(x[['year']])]

  # Extract the year from the sheet name

  x[['year']] <- year_split(x[['year']])

  # Set the column headers. First ensure that there are the same number of
  # columns as there are column names.

  col_names <- c('year','product_short','product', y$SIC)

  # Drop extraneous columns

  x <- x[,1:length(col_names)]

  # Rename the columns to the extracted headers

  colnames(x) <- col_names

  # Now put the data into a sensible long format, and format the columns into
  # sensible formats. Note that SIC needs to remain factor as it contains some
  # characters

  x <- tidyr::gather_(
    data = x,
    key = 'SIC',
    value = 'gva',
    gather_cols = y$SIC
  )

  # Finally save out to a *.Rds file

  message(
    '################################# WARNING #################################
    The data produced by this function may contain OFFICIAL information.
    Ensure that the data are not committed to a github repository.
    Tools to prevent the accidental committing of data are available at:
    https://github.com/ukgovdatascience/dotfiles.'
  )

  return(x)

}

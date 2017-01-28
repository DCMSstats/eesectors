#' @title extract list of DCMS sectors from ONS working file spreadsheet
#'
#' @description The data which underlies the Economic Sectors for DCMS sectors
#'   data is typically provided to DCMS as a spreadsheet from the Office for
#'   National Statistics. This function extracts the list of sectors that DCMS
#'   are responsible for. This information is recorded in the methodology note
#'   which accompanies the publication at
#'   \url{https://www.gov.uk/government/publications/dcms-sectors-economic-estimates-methodology}
#'   and a version correct at the time of the 2016 release is included in the
#'   package as \code{eesectors::DCMS_sectors}.
#'
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

extract_DCMS_sectors <- function(
  x,
  sheet_name = 'Working File',
  output_path = '.',
  skip = 7,
  sectors = c('creative','digital','culture','telecoms','gambling','sport','tourism','all_dcms')
) {

  x <- readxl::read_excel(x, sheet = sheet_name, skip = skip)

  # Fix the messy column names

  col_names <- make.names(colnames(x), unique = TRUE)
  col_names <- tolower(col_names)
  col_names <- gsub('\\.\\.+?', '_', col_names)
  col_names <- gsub('\\.', '_', col_names)
  col_names <- gsub('\\_$', '', col_names)

  # Replace the old column names with the new cleaned ones

  colnames(x) <- col_names

  # Select out the columns of interest. Drop broadcasting here as not required.

  x <- x[, c('sic','description', sectors)]

  # Pivot the data to make it long

  x <- tidyr::gather_(x, key_col = 'sector', value_col = 'present', gather_cols = sectors)

  # Rename sic to SIC. Slightly unwieldly bit of code here. See:
  # http://stackoverflow.com/questions/26619329/dplyr-rename-standard-evaluation-function-not-working-as-expected

  x <- dplyr::rename_(x, .dots = setNames("sic", "SIC"))

  # Check that there are not NAs (i.e. there will be a *), and assign TRUE or
  # FALSE as appropriate. Also need to make an manual intervention on SIC=30.12.

  x <- dplyr::mutate_(
    .data = x,
    "present" = ~ifelse(!is.na(present), TRUE, FALSE),
    "SIC2" = ~ifelse(SIC == '30.12', '30.1', substr(SIC, 1, 2))
  )

  # Note that there are a number of blank rows that get picked up during this
  # operation. These are dropped here. This also drops the row that says 'TOURISM
  # (Only available 2011-2015)' without SIC codes.

  x <- x[!(is.na(x[['SIC']]) & is.na(x[['SIC2']])),]

  # Quick fix for the tourism (62.011) entry

  x <- dplyr::mutate_(
        .data = x,
        "description" = ~ifelse(SIC == 62.011, 'Tourism', description),
        "present" = ~ifelse(SIC == 62.011 & sector %in% c('tourism', 'all_dcms'), TRUE, present)
      )

  full_path <- file.path(output_path, 'DCMS_sectors.Rds')

  save_rds(x, full_path = full_path)

}

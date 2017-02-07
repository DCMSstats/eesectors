#' @title extract list of DCMS sectors from ONS working file spreadsheet
#'
#' @description The data which underlies the Economic Sectors for DCMS sectors
#'   data is typically provided to DCMS as a spreadsheet from the Office for
#'   National Statistics. This function extracts the list of sectors that DCMS
#'   are responsible for from the working_file_dcms_V13.xlsm spreadsheet. This
#'   information is also recorded in the methodology note which accompanies the
#'   publication at
#'   \url{https://www.gov.uk/government/publications/dcms-sectors-economic-estimates-methodology}
#'    and a version correct at the time of the 2016 release is included in the
#'   package as \code{eesectors::DCMS_sectors}. Hence, it is not necessary to
#'   run this function every time - only if changes to the DCMS sectors are
#'   made.
#'
#' @details The best way to understand what happens when you run this function
#'   is to look at the source code, which is available at
#'   \url{https://github.com/ukgovdatascience/eesectors/blob/master/R/}. A brief
#'   explanation of what the function does here:
#'
#'   1. The function calls \code{readxl::read_excel} to load the appropriate
#'   page from the underlying spreadsheet.
#'
#'   2. The column names are sanitised and cleaned to remove extraneous
#'   characters, and are made all lower case
#'
#'   3. The dataframe is limited to the columns: \code{'sic'},
#'   \code{'description'}, and those contained in the \code{sector} argument:
#'   \code{c('creative', 'digital', 'culture', 'telecoms', 'gambling', 'sport',
#'   'tourism', 'all_dcms')}.
#'
#'   4. The data are pivoted into long form using \code{tidyr::gather_}. This
#'   converts the data from a wide dataframe with \code{'sector'} as the key
#'   column, and \code{present} as the value column (i.e. present in DCMS
#'   sector?). The result is a much longer dataframe which is much easier to
#'   subset.
#'
#'   5. For consistency with later steps, the \code{'sic'} column is renamed to
#'   \code{'SIC'}.
#'
#'   6. The asterisks used in the spreadsheet to denote presence in a DCMS
#'   sector are replaced by a binary variable with \code{TRUE} and \code{FALSE}
#'   in place of \code{*} and \code{NA}.
#'
#'   7. \code{NA} values created by step 6 are removed from the dataframe.
#'
#'   8. The tourism entry which is formatted differently in the 'working file'
#'   worksheet in working_file_dcms_V13.xlsm is fixed to ensure that it has both
#'   a description and a SIC (where previously it just had a SIC), and 'tourism'
#'   is labelled as a DCMS sector under tourism and all_dcms.
#'
#'   9. The data are saved out to a .Rds file, and a check run to ensure that
#'   the file exists. The size of the new file is reported in bytes.
#'
#' @param x Location of the input spreadsheet file. Named something like
#'   "working_file_dcms_VXX.xlsm".
#' @param sheet_name The name of the spreadsheet in which the data are stored.
#'   Defaults to \code{New ABS Data}.
#' @param skip Number of lines to skip when reading the worksheet, inherits from
#'   \code{readxl::read_excel}.
#' @param sectors A character vector of the sectors for which DCMS is
#'   responsible, currently: \code{c('creative', 'digital', 'culture',
#'   'telecoms', 'gambling', 'sport', 'tourism', 'all_dcms')}.
#'
#' @return The function returns nothing, but saves the extracted dataset to
#'   \code{file.path(output_path, 'DCMS_sectors.Rds')}. This is an R data
#'   object, which retains the column types which would be lost if converted to
#'   a flat format like CSV.
#'
#' @examples
#'
#' \dontrun{
#' library(eesectors)
#' extract_DCMS_sectors(
#' x = 'OFFICIAL_working_file_dcms_V13.xlsm',
#' sheet_name = 'Working File',
#' output_path = '../OFFICIAL/'
#' )
#' }
#' @importFrom stats setNames
#' @export

extract_DCMS_sectors <- function(
  x,
  sheet_name = 'Working File',
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

    message(
      '################################# NOTE #################################
    DCMS sectors as were at publication of the 2016 Economics Estimates for
    DCMS sectors have been included as a dataset withing the eesectors
    package, and should be used in preference to recreating the data from
    the spreadsheet (assuming no changes have occurred). These data can
    be accessed with eesectors::DCMS_sectors.'
    )

    return(x)

}

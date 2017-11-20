#' @title extract ABS data from ONS working file spreadsheet
#'
#' @description The data which underlies the Economic Sectors for DCMS sectors
#'   data is typically provided to DCMS as a spreadsheet from the Office for
#'   National Statistics. This function extracts the ABS data from that
#'   spreadsheet, and saves it to .Rds format.
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
#'   5. All the ABS values are combined into a column called \code{ABS}. In the
#'   2016 spreadsheet there were a number of full stops (\code{.}) in the
#'   \code{ABS} column, which will be coerced to \code{NA} when the the column
#'   is converted to numeric using \code{as.numeric} (the next step). The
#'   internal function \code{eesectors::integrity_check} runs a quick check to
#'   make sure that the only NAs creeping into the \code{ABS} column are from
#'   full stops in the original data. The full stops are then converted to
#'   zeros.
#'
#'   6. The internal function \code{eesectors::clean_sic} is run on the
#'   \code{DOMVAL} column to ensure that all 3 and 4 digit SIC codes are
#'   formatted properly.
#'
#'   7. The data are printed to console, and can be saved out using the normal
#'   methods, for instance \code{saveRDS}, or \code{write.csv}.
#'
#' @param path Location of the input spreadsheet file. Named something like
#'   "working_file_dcms_VXX.xlsm".
#' @param sheet The name of the spreadsheet in which the data are stored.
#'   Defaults to \code{New ABS Data}.
#' @param format Specify which years format the data is in
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
#' extract_ABS_data(
#' path = 'OFFICIAL_working_file_dcms_V13.xlsm',
#' sheet_name = 'New ABS Data'
#' )
#' }
#'
#' @export

extract_ABS_data <- function(
  path,
  sheet = 'New ABS Data',
  format = 2015) {

  #ABS data explanation - in working file, for each full SIC, they look up
  #the GVA from ABS for the full sic and also the two digit part. then the
  #percentage the former of the latter is calculated and used to weight gva

  #readxl will read columns in as numeric if it can
  #the 2016 data contains . in some columns which means the columns will be read
  #in as character
  df <-
    suppressWarnings(
      readxl::read_excel(
        path = path, sheet = sheet))

  # choose where to select excel data from
  if(format == 2015) {
      df <- df[, c(1, 6:12)]
  } else if(format == 2016) {
      df <-
        rbind(
          #df[, c(1, 4:11)], raw data
          df[91:161, 13:21],
          df[c(5:86, 89), 13:21]) %>%
        rename(DOMVAL = Checks)
  } else
      stop("Invalid format argument")

  #remove duplicate SIC 92
  df <- df[-149, ]

  #determine most recent year of data
  years <- suppressWarnings(as.numeric(colnames(df)))
  years <- min(years[!is.na(years)]):max(years[!is.na(years)])

  #replace full stops in data and convert to numeric
  df[, colnames(df) %in% years] <- lapply(
    df[, colnames(df) %in% years],
    function(x) as.numeric(ifelse(x == ".", NA, x)))

  #check for missing columns
  na_col_test(df)

  #convert data to long format
  df <- df %>%
    tidyr::gather_(
      key = "year",
      value = "ABS",
      gather_cols = years) %>%
    filter(!is.na(DOMVAL)) %>%
    filter(!is.na(ABS)) %>%
    mutate(year = as.integer(year)) %>%

    mutate(SIC = DOMVAL) %>%
    select(-DOMVAL)
    #mutate(SIC = eesectors::clean_sic(as.character(DOMVAL))) %>%
    #select(-DOMVAL)

  #check columns names
  if(
    !identical(
      colnames(df),
      c("year", "ABS", "SIC")))
    stop("column names have not been created correctly")

  #check column types
  df_types <- sapply(df, class)
  names(df_types) <- NULL
  if(!identical(df_types, c("integer", "numeric", "character")))
    stop("column classes have not been created correctly")


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
    df,
    years = years,
    class = c("ABS", class(df))
  )

}

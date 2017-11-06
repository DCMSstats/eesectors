#' @title extract GVA data from ONS working file spreadsheet
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
#'   code is relatively transparent and well documented.
#' @param path Location of the input spreadsheet file. Named something like
#'   "working_file_dcms_VXX.xlsm".
#' @param sheet The name of the spreadsheet in which the data are stored.
#'   Defaults to \code{New ABS Data}.
#' @param ... passes arguments to \code{readxl::read_excel()} which is the basis
#'   of this function
#'
#' @export


#excel file explantion
#first matches against list of SICs which has some text headings removed
#but keeps the 30.1-4 and 30other types
#then it is matched against the two digit (except 30.1) SICs in Working
#File sheet. So is very simple we are doing no grouping.

extract_GVA_data <- function(
  path,
  sheet = "CP Millions",
  dstart = c(15, 3),
  dend = c(40, 184),
  cnames = 5
) {

  #extract GVA data separately to SIC codes to keep it as numeric type

  #even with skip option, readxl annoyingly skips first blank row so need to minus 1
  #note this behaviour is different but still skips in more recent versions
  dstart[1] <- dstart[1] - 1
  dend[1] <- dend[1] - 1
  cnames <- cnames - 1

  #suppress warnings that text data is being converted to numeric
  data <- suppressWarnings(
    readxl::read_excel(
      path = path,
      sheet = sheet,
      col_names = FALSE,
      col_types = rep("numeric",dend[2]))
  )

  data2 <- data.frame(t(data[dstart[1]:dend[1], (dstart[2] + 1):dend[2]]))
  colnames(data2) <- unlist(data[dstart[1]:dend[1], dstart[2]])

  SIC <- readxl::read_excel(
    path = path,
    sheet = sheet,
    col_names = FALSE)

  SIC <- as.character(t(SIC[cnames, (dstart[2] + 1):dend[2]]))
  gva <- cbind(SIC, data2, stringsAsFactors = FALSE)

  gva <- gva %>%
    filter(SIC %in% eesectors::DCMS_sectors$SIC2)

  #determine most recent year of data
  years <- suppressWarnings(as.numeric(colnames(gva)))
  years <- min(years[!is.na(years)]):max(years[!is.na(years)])

  #check for missing columns
  na_col_test(gva)

  #check number of SIC codes in dataset
  if (nrow(gva) != length(unique((eesectors::DCMS_sectors$SIC2))))
    stop(
      paste0(
        "GVA data has rows for ",
        nrow(gva),
        " 2-digit SIC codes. there are ",
        length(unique((eesectors::DCMS_sectors$SIC2))),
        " in eesectors::DCMS_sectors"))

  #convert data to long format
  gva2 <- gva %>%
    tidyr::gather_(key = "year", value = "GVA", gather_cols = years) %>%
    mutate(year = as.integer(year)) %>%
    as.tbl()

  #check columns names
  if(
    !identical(
      colnames(gva2),
      c("SIC", "year", "GVA")))
    stop("column names have not been created correctly")

  #check column types
  gva_types <- sapply(gva2, class)
  names(gva_types) <- NULL
  if(!identical(gva_types, c("character", "integer", "numeric")))
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
    gva2,
    years = years,
    class = c("GVA", class(gva2))
  )
}

#' @title Extract employment data from APS SPSS file
#'
#' @description The employment data which underlies the Economic Sectors for
#'   DCMS sectors data is typically provided to DCMS as an SPSS .sav file from
#'   the Office for National Statistics. This function extracts the employment
#'   data from that spreadsheet, from which point it can be saved as an .Rds
#'   file.
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
#'   1. The function calls \code{haven::read_spss} to read in the APS file.
#'
#'   2. Only the columns which are actually used are selected out from the data
#'   using the \code{keep_variables} argument.
#'
#'   3. The APS data used for the Economic Estimates is returned.
#'
#' @param x Location of the input spreadsheet file. Named something like
#'   "APSP_JDXX_CLIENT_PWTA14.sav".
#' @param keep_variables Character vector of variables to be retained after
#'   import from SPSS format. These currently default to: "INDC07M" (SIC for
#'   main job - 4 digits), "INDC07S" (SIC for second job - 4 digits), "INDSC07M"
#'   (SIC for main job - 5 digits), "INDSC07S" (SIC for second job - 5 digits),
#'   "SOC10M" (SOC for main job), "SOC10S" (SOC for second job), "INECAC05"
#'   (Employment status), "SECJMBR" (Employment status in second job), "PWTA14"
#'   (Weights), "SEX", "AGES", "ETHUK11", (Ethnicty), "NATOX7" (Nationality),
#'   "FTPT" (Full time / part time), "HIQUL15D" (Highest qualification),
#'   "GORWKR" (Region of first job), "GORWK2R" (Region of second job),
#'   "REFWKY" (Reference week year).
#'
#' @return The function returns the APS data as a dataframe.
#'
#' @examples
#'
#' \dontrun{
#' library(eesectors)
#' extract_APS_data(
#' x = '~/Data/APSP_JD15_CLIENT_PWTA14.sav'
#' )
#' }
#'
#' @export

extract_APS_data <- function(
  x,
  keep_variables = c(
    "INDC07M", "INDC07S", "INDSC07M", "INDSC07S",
    "SOC10M", "SOC10S", "INECAC05", "SECJMBR",
    "PWTA14", "SEX", "AGES", "ETHUK11", "NATOX7",
    "FTPT", "HIQUL15D", "GORWKR", "GORWK2R", "REFWKY"
  )
  ) {

  # Read the APS data
  APSdata <- haven::read_spss(x)
  colnames(APSdata) <- toupper(colnames(APSdata))

  # Modify the keep variables if year < 2014
  year <- eesectors:::yearfind(APSdata)
  if (year<2015){
    names(APSdata)[names(APSdata)=="HIQUL11D"] <- "HIQUL15D"
  }

  # Select only the needed data
  APSdata <- APSdata[,keep_variables]

  # Return a data frame of only the data we need
  return(APSdata)
  return(assign(paste0("aps",eesectors:::yearfind(APSdata)), APSdata, envir = globalenv()))
}

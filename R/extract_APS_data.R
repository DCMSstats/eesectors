#' @title extract employment data from APS SPSS file
#'
#' @description The employment data which underlies the Economic Sectors for DCMS sectors
#'   data is typically provided to DCMS as an SPSS .sav file from the Office for
#'   National Statistics. This function extracts the employment data from that
#'   spreadsheet, from which point it can be saved as an .Rds file.
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
#'   1. The function calls \code{foreign::read.spss} and reads in the APS file.
#'
#'   2. Only the columns which are actually used are selected out from the data.
#'
#'   3. The APS data used for the Economic Estimates is returned.
#'
#' @param x Location of the input spreadsheet file. Named something like
#'   "APSP_JDXX_CLIENT_PWTA14.sav".
#'
#' @return The function returns the APS data as a dataframe
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

extract_APS_data <- function(x){

  # Read the APS data
  APSdata=foreign::read.spss(x, to.data.frame = TRUE, use.value.labels = FALSE)

  # Build an array of the names of the needed columns
  keep_variables=c("INDC07M",      # SIC for main job (4 digits)
                   "INDC07S",      # SIC for second job (4 digits)
                   "INDSC07M",     # SIC for main job (5 digits)
                   "INDSC07S",     # SIC for second job (5 digits)
                   "SOC10M",       # SOC for main job
                   "SOC10S",       # SOC for second job
                   "INECAC05",     # Employment status
                   "SECJMBR",      # Employment status in second job
                   "PWTA14",       # Weights
                   "SEX",          # Sex
                   "AGES",         # Age
                   "ETHUK11",      # Ethnicty
                   "NATOX7",       # Nationality
                   "FTPT",         # Full time / part time
                   "HIQUL15D",     # Highest qualification
                   "GORWKR",       # Region of first job
                   "GORWK2R")      # Region of second job

  # Select only the needed data
  APSdata <- APSdata[,keep_variables]

  # Return a data frame of only the data we need
  return(APSdata)
}

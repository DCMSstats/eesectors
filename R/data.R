#' GVA data for 2010:2015.
#'
#' Data extracted from the 2016 Economic Estimates of DCMS Sectors 2016 report.
#' These data are provided for testing ouputs of this package against, and for
#' the initial development phase during which the original data sources were not
#' available.
#'
#' @format A tibble with 54 rows and 3 variables:
#' \describe{
#'   \item{sector}{DCMS sector, one of: \code{c('creative','culture','digital',
#'   'gambling','sport','telecoms','tourism', 'UK', 'all_dcms')}, note that
#'   \code{all_dcms} is not the sum of the other sectors, due to overlap between
#'    sectors.}
#'   \item{year}{calendar year.}
#'   \item{GVA}{gross value added (GBP millions).}
#' }
#' @source
#' \url{https://www.gov.uk/government/statistics/dcms-sectors-economic-estimates-2016}
#'
#' @keywords Economic Estimates Sectors DCMS
"GVA_by_sector_2016"

#' DCMS sectors in 2016.
#'
#' These data are essentially a list of all United Nations (UN) Standard
#' Industrial Codes (SIC), along with an indication of which broad sector the
#' code belongs to, and whether it was used by DCMS in the sectors economic
#' estimates released in 2016. These data are provided in the the methodology
#' note that accompanies the 2016 Statistical First Release
#' (https://www.gov.uk/government/publications/dcms-sectors-economic-estimates-methodology),
#' although this particular dataset was extracted from the 'Working sheet'
#' worksheet of the \code{working_file_dcms_V13.xlsm} spreadsheet using the
#' \code{extract_DCMS_sectors} function.
#'
#' @format A tibble with 552 rows and 5 variables:
#' \describe{
#'   \item{SIC}{Four digit United Nations Standard Industrial Code (SIC).}
#'   \item{description}{Description of the four digit SIC code.}
#'   \item{sector}{DCMS sector to which the particular SIC code belongs.}
#'   \item{present}{Is the particular SIC code present in the relevant DCMS
#'   sector?}
#'   \item{SIC2}{Two digit SIC code.}
#' }
#' @source
#' \url{https://www.gov.uk/government/publications/dcms-sectors-economic-estimates-methodology}
#'
#' @keywords Economic Estimates Sectors DCMS
"DCMS_sectors"

#' GVA by sectors (Table 3.1).
#'
#' Table 3.1 from the 2016 Economic Estimates for DCMS Sectors publication. This
#' dataset is included for testing purposes.
#'
#' @format A tibble with 10 rows and 10 variables.
#' @source
#' \url{https://www.gov.uk/government/statistics/dcms-sectors-economic-estimates-2016}
#'
#' @keywords Economic Estimates Sectors DCMS
"GVA_table"
#' GVA data for 2010:2015.
#'
#' Data extracted from the 2016 Economic Estimates of DCMS Sectors 2016 report.
#' These data are provided for testing ouputs of this package against, and for
#' the initial development phase during which the original data sources were not
#' available.
#'
#' @format A tibble with 40 rows and 3 variables: \describe{ \item{sector}{DCMS
#'   sector, one of: \code{ c('Creative Industries','Cultural Sector','Digital
#'   Sector','Gambling','Sport','Telecoms','Tourism', 'UK', 'all_dcms') },
#'   note that \code{all_dcms} is not the sum of the other sectors, due to
#'   overlap between sectors.} \item{year}{calendar year.} \item{exports}{Exports of services (GBP millions).}}.
#' @source
#' \url{https://www.gov.uk/government/statistics/dcms-sectors-economic-estimates-2016}
#'
#' @keywords Economic Estimates Sectors DCMS
"exports_by_sector_2016"

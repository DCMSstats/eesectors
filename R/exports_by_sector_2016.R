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

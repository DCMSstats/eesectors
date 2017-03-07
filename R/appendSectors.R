#' @title Append sector membership to APS data extract
#'
#' @description This function appends DCMS sector membership to an APS
#'   SPSS-extracted data frame.
#'
#' @details The function \code{eesectors::extract_APS_data} extracts APS data
#'   from an APS SPSS file. This function appends DCMS sector membership to an
#'   APS SPSS-extracted data frame before further analysis, on a first job and
#'   second job basis
#'
#'   1. The function converts the character vector DCMS_sectors$SIC to double
#'
#'   2. The function loops through the sectors found in DCMS_sectors, and uses
#'   DCMS_sectors as a lookup for membership of each person's main and second
#'   job in each sector
#'
#'   3. The function adds membership in the form of two variables per sector
#'
#'   4. The dataframe with +2*n_sectors variables is returned
#'
#' @param x a `data.frame` as extracted by \code{eesectors::extract_APS_data}
#' @param sectors a `data.frame` as extracted by
#'   \code{eesectors::extract_DCMS_sectors}. This defaults to the `DCMS_sectors`
#'   object which is the `extract_DCMS_sectors` function applied to the 2016
#'   data.
#'
#' @return The function returns the APS data as a dataframe with the sector
#'   membership variables appended
#'
#' @examples
#'
#' \dontrun{
#' library(eesectors)
#' APS_data_sectors=appendSectors(
#' x = APS_data
#' )
#' }
#'
#' @export

appendSectors <- function(x, sectors = eesectors::DCMS_sectors){

  # Get the SICs into the right format
  sectors$SIC_long <- elongate_SIC(sectors$SIC)
  #DCMS_sectors2$SIC<-as.numeric(gsub("[.]", "", DCMS_sectors$SIC))

  # Find out how many sectors there are
  unique_sectors <- unique(sectors$sector)

  # Loop for each sector in sectors
  for (s in unique_sectors){
    x[paste0(s,"_main")] <- FALSE
    x[paste0(s,"_second")] <- FALSE

    # Find the SIC codes that define the sector (where DCMC sectors is =s, and
    # then where that SIC is TRUEly present in that sector)
    sector_mask <- eesectors::DCMS_sectors$sector==s
    SIC <- sectors$SIC_long[sector_mask][eesectors::DCMS_sectors$present[sector_mask]==TRUE]

    # If a person has a job in that sector, per sector, per main/2nd job then
    # "TRUE"
    x[paste0(s,"_main")] <- x$INDC07M %in% SIC
    x[paste0(s,"_second")] <- x$INDC07S %in% SIC
  }
  return(x)
}


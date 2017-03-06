#' @title Append sector membership to APS data extract
#'
#' @description This function appends DCMS sector membership to an APS
#' SPSS-extracted data frame.
#'
#' @details The function \code{eesectors::extract_APS_data} extracts APS data
#' from an APS SPSS file. This function appends DCMS sector membership to an APS
#' SPSS-extracted data frame before further analysis, on a first job and second job basis
#'
#'   1. The function converts the character vector DCMS_sectors$SIC to double
#'
#'   2. The function loops through the sectors found in DCMS_sectors, and uses DCMS_sectors
#'   as a lookup for membership of each person's main and second job in each sector
#'
#'   3. The function adds membership in the form of two variables per sector
#'
#'   4. The dataframe with +2*n_sectors variables is returned
#'
#' @param x a data frame as extracted by \code{eesectors::extract_APS_data}
#'
#' @return The function returns the APS data as a dataframe with the sector membership
#' variables appended
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

appendSectors <- function(x){

  # Get the SICs into the right format
  DCMS_sectors2 <- DCMS_sectors
  DCMS_sectors2$SIC<-round(as.numeric(DCMS_sectors$SIC)*100)
  #DCMS_sectors2$SIC<-as.numeric(gsub("[.]", "", DCMS_sectors$SIC))

  # Find out how many sectors there are
  sectors <- unique(DCMS_sectors$sector)

  # Create an new data frame with the sectors
  APS_data_sectors <- x

  # Loop for each sector in sectors
  for (s in sectors){
    APS_data_sectors[paste0(s,"_main")] <- FALSE
    APS_data_sectors[paste0(s,"_second")] <- FALSE

    # Find the SIC codes that define the sector
    # (where DCMC sectors is =s, and then where that SIC is TRUEly present in that sector)
    SIC=DCMS_sectors2$SIC[DCMS_sectors$sector==s][DCMS_sectors$present[DCMS_sectors$sector==s]==TRUE]

    # If a person has a job in that sector, per sector, per main/2nd job then "TRUE"
    APS_data_sectors[paste0(s,"_main")]<-APS_data_sectors$INDC07M %in% SIC
    APS_data_sectors[paste0(s,"_second")]<-APS_data_sectors$INDC07S %in% SIC
  }
  return(APS_data_sectors)
}


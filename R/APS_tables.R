#' @title Sector employment time series table
#'
#' @description Produces a time series table of employment by DCMS sector
#'
#' @details The function \code{eesectors::jobs_timeseries} produces a basic time series
#'   of data based on jobs per DCMS sector.
#'
#' @param ... APS time series `data.frames`s or the file destinations of APS datasets
#'   (providing APS data sets will cause the function to run slowly as it loads the data)
#'
#' @return The function returns the sector employment time series table
#'
#' @examples
#'
#' \dontrun{
#' library(eesectors)
#' employment_timeseries <- jos_timeseries(
#' aps2011, aps2012, aps2013, aps2014, aps2015
#' )
#' }
#'
#' \dontrun{
#' library(eesectors)
#' employment_timeseries <- jos_timeseries(
#' "./APS_data_2013.sav","./APS_data_2014.sav","./APS_data_2015.sav",
#' )
#' }
#'
#' @export
#'

jobs_timeseries <- function(...,tourism=NULL,sectors = eesectors::DCMS_sectors){

  #Time seriesify the data and do sector analysis

  message("Combining data frames...")
  APS_ts <- eesectors:::APS_timeseries(...)
  message("Adding sector membership for first and second jobs...")
  APS_ts <- lapply(APS_ts,eesectors::appendSectors)
  message("Counting jobs per sector per person...")
  APS_ts <- lapply(APS_ts,eesectors:::sector_jobs)

  #Start to build the table

  #Get sector names
  sector_names <- sapply(unique(sectors$sector),eesectors:::simpleCap)

  #Add column 1, sector names
  jobs_ts <- data.frame(Sector <- c(sector_names))
  jobs_ts[,1] <- gsub(jobs_ts[,1],pattern = "All_dcms",replacement = "All DCMS")

  #If there is Tourism data to read, read it in
  if  (!is.null(tourism)){
    tdata<-readxl::read_excel(tourism)
  }

  #Add jobs statistics
  for (year in APS_ts){
    jobs_count<-eesectors:::sector_jobs_count(year)
    jobs_ts[toString(eesectors:::yearfind(year))]<-NA

    if (!is.null(tourism)){
      jobs_count["tourism",]<-tdata$`Tourism employment`[tdata$Year==eesectors:::yearfind(year)]
      jobs_count["all_dcms",]<-jobs_count["all_dcms",]+tdata$`Tourism employment`[tdata$Year==eesectors:::yearfind(year)]-tdata$Overlap[tdata$Year==eesectors:::yearfind(year)]
    }

    jobs_ts[toString(eesectors:::yearfind(year))]<-jobs_count
  }

  return(jobs_ts)
}


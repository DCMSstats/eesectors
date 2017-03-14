#' @title Sector jobs
#'
#' @description Counts the number of jobs a person has in each sector (0, 1 or 2)
#'
#' @details This function sums up the jobs per sector found using the appendSectors
#'   function.
#'
#' @param x a `data.frame` as extracted by \code{eesectors::extract_APS_data}
#'
#' @return The function returns the APS data as a dataframe with the sector
#'   job count variables appended
#'
#' @examples
#'
#' \dontrun{
#' library(eesectors)
#' APS_data_jobs=sector_jobs(APS_data)
#' )
#' }
#'

sector_jobs<-function(x){

  # Find out how many sectors there are
  unique_sectors <- unique(DCMS_sectors$sector)

  for(s in unique_sectors){
    x[s] <- x[paste0(s,"_main")]+x[paste0(s,"_second")]
  }
  return(x)
}

#' @title Sector jobs count
#'
#' @description Counts the number of jobs per sector, after removing those
#'   without a second or first jobs
#'
#' @details Counts the number of jobs per sector, after removing those
#'   without a second or first jobs using the \code{eesectors:::main_job_mask}
#'   and \code{eesectors:::second_job_mask} functions.
#'
#' @param x an APS `data.frame` as extracted by \code{eesectors::extract_APS_data}
#'   and with sectors added with \code{eesectors::appendSectors} and
#'   \code{eesectors:::sector_jobs}
#'
#' @return The function returns a `data.frame` contains the jobs per DCMS sector
#'
#' @examples
#'
#' \dontrun{
#' library(eesectors)
#' job_counts_20xx=sector_jobs_count(APS_data_secotr_jobs)
#' )
#' }
#'

sector_jobs_count<-function(x){

  # Find out how many sectors there are
  unique_sectors <- unique(DCMS_sectors$sector)

  # create output df
  y <- data.frame(matrix(, nrow=length(unique_sectors), ncol=0))
  row.names(y) <- unique_sectors

  # create masked data sets of first/second jobs only
  xm<-eesectors:::main_job_mask(x)
  xs<-eesectors:::second_job_mask(x)

  # get the jobs per sector and weight by PWTA14
  for(s in unique_sectors){
    y[s,"count"] <- sum(xm[paste0(s,"_main")]*xm$PWTA14)+sum(xs[paste0(s,"_second")]*xs$PWTA14)
  }
  return(y)
}

#' @title Economic activity filters
#'
#' @description Filters out people based on their main/second job
#'   economic activity status
#'
#' @details Filters out people based on their main/second job
#'   economic activity status - INECAC05 for first job and SECJMBR for second
#'   job (1 = full time, 2 = part time).
#'
#' @param x a `data.frame` as extracted by \code{eesectors::extract_APS_data}
#'
#' @return The function returns the APS `data.frame` with only those
#'   with a first or second job depending on functions used.
#'
#' @examples
#'
#' \dontrun{
#' library(eesectors)
#' APS_data_jobs=sector_jobs(APS_data)
#' )
#' }
#'

main_job_mask<-function(x){
  return(x[x$INECAC05==1 | x$INECAC05==2 & !is.na(x$INECAC05),])
}

second_job_mask<-function(x){
  return(x[(x$SECJMBR==1 | x$SECJMBR==2) & !is.na(x$SECJMBR),])
}




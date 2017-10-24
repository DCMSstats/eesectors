#' @title Recode functions
#'
#' @description Recodes various APS functions into ones usable
#' for the analysis
#'
#' @details These functions recode APS variables into variales
#' useful for the statistical release, for example, the regional variables
#' into NUTS1/GOR regions
#'
#' @param x a `data.frame` column as extracted by \code{eesectors::extract_APS_data}
#'
#' @return The function returns the APS variable as a dataframe column with recoded
#' regional variables
#'
#' @examples
#'
#' \dontrun{
#' library(eesectors)
#' APS_data_jobs$var<-regionsRecode(APS_data$var)
#' )
#' }
#'

regionsRecode<-function(x){
  1 ->x[x==1|x==2]
  2 ->x[x==3|x==4|x==5]
  3 ->x[x==6|x==7|x==8]
  4 ->x[x==9]
  5 ->x[x==10|x==11]
  6 ->x[x==12]
  7 ->x[x==13|x==14|x==15]
  8 ->x[x==16]
  9 ->x[x==17]
  10->x[x==18]
  11->x[x==19|x==20]
  12->x[x==21]
  13->x[x==22|x==23]

  x <- labelled::labelled(x, c("North East"=1, "North West"=2,
                     "Yorkshire and The Humber"=3,
                     "East Midlands"=4,"West Midlands"=5,
                     "East of England"=6,"London"=7,
                     "South East"=8,"South West"=9,
                     "Wales"=10,"Scotland"=11,
                     "Northern Ireland"=12,
                     "Other"=13))

  return(x)
}

secondjobRecode<-function(x){
  1 ->x[x==3]
  return(x)
}

ethnicityRecode<-function(x){
  1 ->x[x==1]
  2 ->x[x==3]
  3 ->x[x==4|x==5|x==6|x==7|x==8]
  4 ->x[x==9]
  5 ->x[x==10|x==11|x==2]

  x <- labelled::labelled(x, c("White"=1, "Mixed / Multiple ethnic groups"=2,
                               "Asian / Asian British"=3,
                               "Black / African / Caribbean / Black British"=4,
                               "Other"=5, "Missing"=0))

  return(x)
}




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

  # Append sectors
  x<-eesectors::appendSectors(x)

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




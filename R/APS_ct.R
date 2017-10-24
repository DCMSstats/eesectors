#' @title APS Crosstabber
#'
#' @description Crosstabulates two variables from an APS dataframe
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
#'   1. The function checks if the inputs are file directories or data frames
#'
#'   2. The function finds the year of each inputted dataset
#'
#'   3. The function returns a list of datasets named per year (x$y20XX)
#'
#' @param ... either the locations fo the APS SPSS files from which you want
#'   to form the time series, or the data frames you want to form into the time
#'   series list.
#'
#' @return The function a list of APS data frames, with each list element named
#'   after the year from which the data come
#'
#' @examples
#'
#' \dontrun{
#' library(eesectors)
#' ct<-APS_ct(data, x, y)
#' }
#'
#'

APS_ct <- function(data,x,y,sector="all_dcms"){

  #Run append sectors on the data frame to make sure they're assigned
  data<-eesectors::appendSectors(data)

  #Make sure we've worked out if each person has a job in a sector
  data<-eesectors:::sector_jobs(data)

  jobfilter<-data[,sector]>0
  data<-data[jobfilter,]

  tab<-questionr::wtd.table(x=as.data.frame(data[,y]),y=as.data.frame(data[,x]),weights = as.data.frame(data[,"PWTA14"]))

  return(tab)
  }

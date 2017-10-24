#' @title APS time series maker
#'
#' @description Builds a list of APS data frames by year that can be passed to
#'   other table making functions
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
#' extract_APS_data(...)
#' }
#'
#'

APS_timeseries <- function(...){

  # List the input datasets, if reading from file
  if (typeof(c(...))=="character"){

    # Warn if it doesn't look like an SPSS file (it should fail anyway)
    for(i in c(...)){
      if(substr(i, nchar(i)-3, nchar(i)) != ".sav"){
        warning("At least one file does not appear to be a .sav file. Are you sure this is an SPSS file?")
        break
      }
    }

    # This takes ages if it's importing multiple SPSS datasets
    # Haven doesn't have column selection functionality yet...
    message(paste0("Importing ",toString(length(c(...)))," SPSS files. This may take a few minutes..."))

    # Listify the data imported by eesectors::extract_APS_data
    ts_list <- c(...)
    ts_list <- lapply(ts_list,eesectors::extract_APS_data)
  }

  # Or list the data frames if supplied with data frames
  if (typeof(c(...))=="list"){
    ts_list <- list(...)
    message(paste0(toString(length(ts_list))," data frames supplied"))
  }

  # Find the year of each data set and rename the list element accordingly
  rlist <- lapply(ts_list,eesectors:::yearfind)
  names(ts_list) <- paste0("y",rlist)

  message(paste0(toString(length(ts_list))," APS datasets added to time series"))
  message("Time series consists of the following years, in this order:")
  for(y in rlist){message(y)}

  return(ts_list)
}


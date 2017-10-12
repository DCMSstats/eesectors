#' @title Combine GVA, ABS, SIC91, and Tourism datasets
#'
#' @description Combines datasets exracted from the underlying spreadsheet using
#'   the \code{extract_XXX} functions. A notebook version of this function
#'   (which may be easier to debug) can be downloaded using the
#'   \code{get_GV_combine()} function. Note that this function in its current
#'   form will only work to reproduce the 2016 SFR, and requires adjustment to
#'   generalise it over new years.
#'
#'   NOTE: THIS FUNCTION RELIES ON DATA WHICH ARE CLASSIFIED AS
#'   OFFICIAL-SENSITIVE. THE OUTPUT OF THIS FUNCTION IS AGGREGATED, AND
#'   PUBLICALLY AVAILABLE IN THE FINAL STATISTICAL RELEASE, HOWEVER CARE MUST BE
#'   EXERCISED WHEN CREATING A PIPELINE INCLUDING THIS FUNCTION. IT IS HIGHLY
#'   ADVISEABLE TO ENSURE THAT THE DATA WHICH ARE CREATED BY THE \code{extract_}
#'   FUNCTIONS ARE NOT STORED IN A FOLDER WHICH IS A GITHUB REPOSITORY TO
#'   MITIGATE AGAINST ACCIDENTAL COMMITTING OF OFFICIAL DATA TO GITHUB. TOOLS TO
#'   FURTHER HELP MITIGATE THIS RISK ARE AVAILABLE AT
#'   https://github.com/ukgovdatascience/dotfiles.
#'
#' @details The best way to understand what happens when you run this function
#'   is to look at the \code{inst/combine_GVA.Rmd} notebook, which can be
#'   downloaded automatically using the \code{get_GV_combine()} function, or by
#'   visiting
#'   \url{https://github.com/ukgovdatascience/eesectors/blob/master/inst/combine_GVA.Rmd}.
#'    A brief explanation of what the function does here:
#'
#'   1. Remove SIC 91 data from \code{ABS} and swap in values from \code{SIC91})
#'   2. Duplicate the 2014 \code{ABS} values to use for 2015 (2015 values not
#'   being available - this may change in future years.). 2. Merge the
#'   \code{eesectors::DCMS_sectors} into \code{ABS} to get the 2 digit SIC code.
#'   3. Calculate sums across sectors and years. 4. Add in total UK GVA from
#'   \code{GVA}. 5. Match in \code{tourism} data. 6. Add \code{tourism} overlap.
#'   7. Build the dataframe into a format that is expected by the
#'   \code{year_sector_data} class.
#'
#' @param ABS ABS data as extracted by \code{eesectors::extract_ABS_data()}.
#' @param GVA ABS data as extracted by \code{eesectors::extract_GVA_data()}.
#' @param SIC91 ABS data as extracted by \code{eesectors::extract_SIC91_data()}.
#' @param DCMS_sectors ABS data as extracted by
#'   \code{eesectors::extract_DCMS_sectors()} or matching the
#'   \code{eesectors::DCMS_sectors} in-built dataset.
#' @param tourism ABS data as extracted by \code{eesectors::extract_tourism_data()}.
#' @param log_level The severity level at which log messages are written from
#' least to most serious: TRACE, DEBUG, INFO, WARN, ERROR, FATAL. Default is
#' level is INFO. See \code{?flog.threshold()} for additional details.
#' @param log_appender Defaults to write the log to "console", alternatively you
#' can provide a character string to specify a filename to also write to. See
#' for additional details \code{?futile.logger::appender.file()}.
#'
#' @return A \code{data.frame} as expected by the \code{year_sector_data} class.
#' Can also return an error log to console or write to file.
#'
#' @examples
#'
#' \dontrun{
#' library(eesectors)
#'
#' input <- 'OFFICIAL_working_file_dcms_V13.xlsm'
#'
#' combine_GVA(
#'   ABS = eesectors::extract_ABS_data(input),
#'   GVA = eesectors::extract_ABS_data(input),
#'   SIC91 = eesectors::extract_ABS_data(input),
#'   DCMS_sectors = eesectors::DCMS_sectors,
#'   tourism = eesectors::extract_ABS_data(input)
#' )
#' }
#'
#' @export
#'
#' @import dplyr

combine_GVA <- function(
  ABS = NULL,
  GVA = NULL,
  SIC91 = NULL,
  DCMS_sectors = eesectors::DCMS_sectors,
  tourism = NULL,
  log_level = futile.logger::INFO,
  log_appender = "console"
) {

  #### 0. Set up error log filename and threshold
  # Set logger severity threshold, defaults to
  # mid level use (only flags info, warnings and errors)
  # Set log_level argument to futile.logger::TRACE for full info
  futile.logger::flog.threshold(log_level)

  # Set where to write the log to
  if (log_appender != "console")
  {
    # if not the default of console then a file called...
    futile.logger::flog.appender(futile.logger::appender.file(log_appender))
  }
  
  #Annual business survey, duplicate 2014 data for 2015 and
  #then duplicate non SIC91 then add SIC 91 with sales data
  ABS_2015 <- filter(ABS, year == 2014) %>%
    mutate(year = 2015) %>%

    #this line makes no sense to me - we are just duplicated rows we already
    #have so surely it is redundant??
    bind_rows(filter(ABS, !SIC %in% unique(SIC91$SIC))) %>%
    bind_rows(SIC91)


  # keep cases from ABS which have integer SIC - which is just a higher level SIC
  denom <- filter(ABS_2015, SIC %in% unique(eesectors::DCMS_sectors$SIC2)) %>%
    select(year, ABS, SIC) %>%
    rename(ABS_2digit_GVA = ABS, SIC2 = SIC)

  #add ABS to DCMS sectors
  GVA_sectors <- left_join(eesectors::DCMS_sectors, ABS_2015, by = c('SIC')) %>%
    rename(ABS_ind_GVA = ABS) %>%
    #drop cases where SIC is not in that sector - should do when building DCMS_sectors
    filter(present == TRUE) %>%
    left_join(denom, by = c('year', 'SIC2')) %>% #add ABS GVA for integer SIC
    mutate(perc_split = ABS_ind_GVA / ABS_2digit_GVA) %>% #split of GVA between SIC by SIC2
    filter(!(is.na(year) & is.na(ABS_ind_GVA))) %>% #rows must have either year or ABS GVA

    #add GVA
    left_join(GVA, by = c('SIC2' = 'SIC', 'year')) %>% #add in GVA if SIC appears in SIC2
    mutate(BB16_GVA = perc_split * GVA)


  # with GVA_sectors sum GVA by year and sector
  # add total, tourism
  GVA_by_sector <- dplyr::group_by(GVA_sectors, year, sector) %>%
    summarise(GVA = sum(BB16_GVA)) %>%

    #append total UK GVA
    bind_rows(
      filter(GVA, grepl('total.*intermediate.*',SIC)) %>%
        mutate(sector = "UK") %>%
        select(year, sector, GVA)
    ) %>%

    #append tourism data - add in by statement for transparency
    bind_rows(
      mutate(tourism, sector = "tourism") %>%
        select(year, sector, GVA)
    )

  #add overlap info from tourism in order to calculate GVA for sector=all_dcms
  tourism_all_sectors <- mutate(tourism, sector = "all_dcms") %>%
    select(year, sector, overlap)

  GVA_by_sector <-
    left_join(GVA_by_sector, tourism_all_sectors, by = c("year", "sector")) %>%
    ungroup() %>%
    mutate(GVA = ifelse(!is.na(overlap), overlap + GVA, GVA)) %>%
    select(-overlap) %>%

    #final clean up
    filter(year %in% 2010:2015) %>%
    mutate(GVA = round(GVA, 2),
           sector = factor(sector),
           year = as.integer(year)) %>%
    select(sector, year, GVA) %>%
    arrange(year, sector)


  ### LOG ISSUE - these might be "changing the world" for the user unexpectedly!
  # Reset threshold to package default
  futile.logger::flog.threshold(futile.logger::INFO)
  # Reset so that log is appended to console (the package default)
  futile.logger::flog.appender(futile.logger::appender.console())

}

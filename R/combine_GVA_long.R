#' @title Combine GVA, ABS, SIC91 datasets in long format -
#'   retaining separate rows for each SIC code
#'
#' @description Combines datasets exracted from the underlying spreadsheet using
#'   the \code{extract_XXX} functions.
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
#'   is to view the source code.
#'
#'
#' @param ABS ABS data as extracted by \code{eesectors::extract_ABS_data()}.
#' @param GVA ABS data as extracted by \code{eesectors::extract_GVA_data()}.
#' @param SIC91 ABS data as extracted by \code{eesectors::extract_SIC91_data()}.
#' @param DCMS_sectors ABS data as extracted by
#'   \code{eesectors::extract_DCMS_sectors()} or matching the
#'   \code{eesectors::DCMS_sectors} in-built dataset.
#'
#'
#' @export
#'
#' @import dplyr

combine_GVA_long <- function(
  ABS = NULL,
  GVA = NULL,
  SIC91 = NULL,
  DCMS_sectors = eesectors::DCMS_sectors) {

  check_class(ABS)
  check_class(GVA)
  check_class(SIC91)


  #Annual business survey, duplicate 2014 data for 2015 and
  #then duplicate non SIC91 then add SIC 91 with sales data
  ABS_2015 <- filter(ABS, year == 2014) %>%
    mutate(year = 2015) %>%

    #this line makes no sense to me - we are just duplicated rows we already
    #have so surely it is redundant??
    bind_rows(filter(ABS, !SIC %in% unique(SIC91$SIC))) %>%

    #simply appending SIC sales data which supplements the ABS for SIC 91
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

  structure(
    GVA_sectors,
    class = c("combine_GVA_long", class(GVA_sectors))
  )
}

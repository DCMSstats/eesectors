#' @title Calculate GVA by sector
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
#' @param combine_GVA_long data output from \code{eesectors::combine_GVA_long()}.
#' @param GVA ABS data as extracted by \code{eesectors::extract_GVA_data()}.
#' @param tourism ABS data as extracted by \code{eesectors::extract_tourism_data()}.
#'
#'
#' @export
#'
#' @import dplyr


GVA_by_sector <- function(
  combine_GVA_long = NULL,
  GVA = NULL,
  tourism = NULL
) {

  check_class(combine_GVA_long)
  check_class(GVA)
  check_class(tourism)

  GVA_by_sector <- dplyr::group_by(combine_GVA_long, year, sector) %>%
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

  structure(
    GVA_by_sector,
    class = c("GVA_by_sector", class(combine_GVA_long)[-1])
  )
}

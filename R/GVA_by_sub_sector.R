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
#'
#' @export
#'
#' @import dplyr


GVA_by_sub_sector <- function(
  combine_GVA_long = combine_GVA_long,
  GVA = GVA,
  sub_sector = NULL
) {

  check_class(combine_GVA_long)
  check_class(GVA)

  GVA_by_sub_sector <- combine_GVA_long %>%
    filter(sector == sub_sector) %>%
    group_by(year, sub_sector_categories) %>%
    summarise(GVA = sum(BB16_GVA)) %>%
    ungroup() %>%

    #append total sector GVA by year
    bind_rows(
      combine_GVA_long %>%
        filter(sector == sub_sector) %>%
        group_by(year) %>%
        summarise(GVA = sum(BB16_GVA)) %>%
        mutate(sub_sector_categories =
                 paste0(toupper(substr(sub_sector, 1, 1)),
                       substr(sub_sector, 2, nchar(sub_sector)))) %>%
        select(year, sub_sector_categories, GVA)
    ) %>%

    #append total UK GVA by year
    bind_rows(
      filter(GVA, SIC == "year_total") %>%
        mutate(sub_sector_categories = "UK") %>%
        select(year, sub_sector_categories, GVA)
    ) %>%

    #final clean up
    filter(year %in% 2010:max(attr(combine_GVA_long, "years"))) %>%
    mutate(#GVA = round(GVA, 2),
           #sub_sector_categories = factor(sub_sector_categories),
           year = as.integer(year)) %>%
    select(sub_sector_categories, year, GVA) %>%
    arrange(year, sub_sector_categories)

  #check "tbl_df"     "tbl"        "data.frame" is class(gva_by sub sector)
  # structure(
  #   GVA_by_sector,
  #   class = c("GVA_by_sector", class(combine_GVA_long)[-1])
  # )

  structure(
    GVA_by_sub_sector,
    years = sort(unique(GVA_by_sub_sector$year)),
    class = c("GVA_by_sector", class(GVA_by_sub_sector)))
}

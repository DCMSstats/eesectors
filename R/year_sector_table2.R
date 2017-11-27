#' @title year_sector_table()
#'
#' @description Generic method to convert tables into wide format
#'
#' @details Generic method to convert tables into wide format
#'
#' @param x Object of \code{class(x) == 'year_sector_data'}.
#' @param html Should the output be an R \code{data.frame} (and \code{tbl} and
#'   \code{tbl_df}) or as html using \code{xtable}.
#' @param fmt Format for values in the table to be displayed as, following
#'   \code{sprintf}.
#' @param ... Passes arguments to \code{print.xtable} and \code{xtable}. Will
#'   silently be dropped if \code{html = FALSE}.
#'
#' @seealso \code{\link{sprintf}}
#'
#' @return wide format table
#'
#' @export

# Define as a method
year_sector_table2 <- function(GVA_by_sub_sector, html, fmt, ...) {

    max_year <- max(attr(GVA_by_sub_sector, "year"))
    measure <- "GVA"

    total2016 <-
      GVA_by_sub_sector[
        GVA_by_sub_sector$sub_sector_categories == "UK" &
          GVA_by_sub_sector$year == 2016,]$GVA

    df <- GVA_by_sub_sector %>%
      #mutate(sector = factor(unname(sectors_set[as.character(sector)]))) %>%

      # calculate the index (index_year=100) variable
      group_by(sub_sector_categories) %>%
      tidyr::spread(key = year, value = GVA) %>%
      mutate(change1516 = (`2016` / `2015` - 1) *100) %>%
      mutate(change1015 = (`2016` / `2010` - 1) *100) %>%
      mutate(ukperc = 100 * `2016` / total2016) %>%

      # mutate_all(function(x) round(x, 1)) %>%
      # mutate(`2010` = round(`2010`, 0)) %>%
      # mutate(`2011` = round(`2011`, 0)) %>%
      # mutate(`2012` = round(`2012`, 0)) %>%
      # mutate(`2013` = round(`2013`, 0)) %>%
      # mutate(`2014` = round(`2014`, 0)) %>%
      # mutate(`2015` = round(`2015`, 0)) %>%
      # mutate(`2016` = round(`2016`, 0)) %>%
      rename(
        `Sub-sector` = sub_sector_categories,
        `% change 2015 - 2016` = change1516,
        `% change 2010 - 2016` = change1015,
        `% of UK GVA 2016` = ukperc
      )

}

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
year_sector_table_index <- function(x, html = FALSE, fmt = '%.1f', ...) {

  sectors_set <- c(
    "charities"   = "Civil Society (Non-market charities)",
    "creative"    = "Creative Industries",
    "culture"     = "Cultural Sector",
    "digital"     = "Digital Sector",
    "gambling"    = "Gambling",
    "sport"       = "Sport",
    "telecoms"    = "Telecoms",
    "tourism"     = "Tourism",
    "all_dcms"    = "All DCMS sectors",
    "perc_of_UK"  = "% of UK GVA",
    "UK"          = "UK"
  )

    max_year <- max(x$year)
    measure <- x$type

    # Extract stats for the whole of the UK ----

    #data.frame(col1 = 1:4, col2 = 3:6) %>% rbind(1:2)

     df <- x$df %>%
       mutate(sector = factor(unname(sectors_set[as.character(sector)]))) %>%

       # calculate the index (index_year=100) variable
       group_by(sector) %>%
       mutate(indexGVA = GVA/max(ifelse(year == min(x$year), GVA, 0)) * 100) %>%

       select(-GVA) %>%
       tidyr::spread(key = year, value = indexGVA) %>%
       mutate(change = (`2016` / `2015` - 1) *100) %>%
       # mutate_all(function(x) round(x, 1)) %>%
       #
       #  mutate(`2010` = round(`2010`, 0)) %>%
       #  mutate(`2011` = round(`2011`, 0)) %>%
       #  mutate(`2012` = round(`2012`, 0)) %>%
       #  mutate(`2013` = round(`2013`, 0)) %>%
       #  mutate(`2014` = round(`2014`, 0)) %>%
       #  mutate(`2015` = round(`2015`, 0)) %>%
       #  mutate(`2016` = round(`2016`, 0)) %>%

       rename(Sector = sector, `% change 2015 - 2016` = change, `2016 (p)` = `2016`)


    df[nrow(df)+1,] <- NA
    df <- df[c(2:9, 1, 11, 10),]
}

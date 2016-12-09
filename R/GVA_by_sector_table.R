#' @title Format GVA by sectors table
#'
#' @description \code{GVA_by_sector_table} Formats the GVA by sectors table labelled as
#'   3.1 in the 2016 Economic estimates of DCMS Sectors statistical release
#'   (\url{https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/544103/DCMS_Sectors_Economic_Estimates_-_August_2016.pdf}).
#'
#' @details \code{GVA_by_sector_table} takes as input a standardised long format GVA data frame, and uses
#'   \code{xtable} to format a pretty html table.
#'
#' @param x Input dataframe.
#' @param html Should the table be output as is or using \code{xtable} as html.
#'
#' @return Properly formatted GVA table for release.
#'
#' @examples
#'
#' library(dplyr)
#' library(eesectors)
#'
#' GVA_by_sector_table(GVA_by_sector_2016)
#'
#' @importFrom dplyr mutate_ filter_
#' @importFrom tidyr spread
#' @import xtable
#' @export

GVA_by_sector_table <- function(x, html = TRUE) {

  tryCatch(
    expr = {

      # Extract the UK GVA

      x$sector <- as.character(x$sector)

      GVA_UK <- dplyr::filter_(x, ~sector == 'UK')

      # Extract the current UK GVA estimate. Expect to pass 2015 as argument to
      # function n future versions.

      GVA_UK_current <- dplyr::filter_(x, ~year == 2015, ~sector == 'UK')
      GVA_UK_current <- GVA_UK_current$GVA / 1000

      # Pivot the dataframe to make it wide

      GVA_table <- dplyr::mutate_(x, GVA = ~GVA / 1000)
      GVA_table <- tidyr::spread_(GVA_table, 'year', 'GVA')

      # Divide all by 1000

      GVA_table <- dplyr::mutate_(
        GVA_table,
        since_2014 = ~relative_to(`2014`,`2015`, digits = 1),
        since_2010 = ~relative_to(`2010`,`2015`, digits = 1),
        UK_perc = ~100 + relative_to(GVA_UK_current, `2015`, digits = 1)
      )

      # Calculate the percentage of UK

      GVA_all_sectors_perc <- dplyr::filter_(x, ~sector %in% c('all_sectors', 'UK'))
      GVA_all_sectors_perc <- tidyr::spread_(GVA_all_sectors_perc, 'sector', 'GVA')
      GVA_all_sectors_perc <- dplyr::mutate_(GVA_all_sectors_perc, perc_of_UK = ~all_sectors/UK)
      GVA_all_sectors_perc <- dplyr::select_(GVA_all_sectors_perc, ~perc_of_UK, ~year)
      GVA_all_sectors_perc <- tidyr::spread_(GVA_all_sectors_perc, 'year', 'perc_of_UK')
      GVA_all_sectors_perc <- GVA_all_sectors_perc * 100
      GVA_all_sectors_perc <- cbind(
        sector = 'perc_of_UK',
        GVA_all_sectors_perc
      )

      GVA_table <- dplyr::bind_rows(
        GVA_table,
        GVA_all_sectors_perc
      )

      GVA_table$sector <- factor(
        GVA_table$sector,
        levels = c(
          'Creative Industries',
          'Cultural Sector',
          'Digital Sector',
          'Gambling',
          'Sport',
          'Telecoms',
          'Tourism',
          'all_sectors',
          'perc_of_UK',
          'UK'
        )
      )

      GVA_table <- dplyr::arrange_(GVA_table, ~sector)

      if (html == TRUE) {

        GVA_table <- xtable::xtable(
          x = GVA_table,
          digits = 1
        )

        print(
          GVA_table,
          type = 'html'
        )

      } else {

        print(GVA_table)

        }

    },
    warning = function() {

      w <- warnings()
      warning('Warning produced GVA_by_sector_table():', w)

    },
    error = function(e)  {

      stop('Error produced running GVA_by_sector_table():', e)

    },
    finally = {}
  )
}


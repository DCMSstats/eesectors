#' @title Format exports by sector table
#'
#' @description \code{exports_by_sector_table} Formats the exports by sectors
#'   table labelled as 3.1 in the 2016 Economic estimates of DCMS Sectors
#'   statistical release
#'   (\url{https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/544103/DCMS_Sectors_Economic_Estimates_-_August_2016.pdf}).
#'
#'
#' @details \code{exports_by_sector_table} takes as input a standardised long
#'   format exports data frame, and uses \code{xtable} to format a pretty html
#'   table.
#'
#' @param x Input dataframe.
#' @param html Should the table be output as is or using \code{xtable} as html.
#' @param max_year The maximum year for which measurements are available for the
#'   given measure. This is experimental, and likely to be removed in favour of
#'   the function determining this for itself from teh data.
#'
#' @return Properly formatted exports table for release.
#'
#' @examples
#'
#' library(dplyr)
#' library(eesectors)
#'
#' exports_by_sector_table(exports_by_sector_2016)
#'
#' @importFrom dplyr mutate_ filter_
#' @importFrom tidyr spread
#' @import xtable
#' @export

exports_by_sector_table <- function(x, max_year = 2014, html = TRUE) {

  tryCatch(
    expr = {

      # Extract the UK exports

      x$sector <- as.character(x$sector)

      exports_UK <- dplyr::filter_(x, ~sector == 'UK')

      # Extract the current UK estimate for estimates. This

      exports_UK_current <- dplyr::filter_(x, ~year == max_year, ~sector == 'UK')
      exports_UK_current <- exports_UK_current$exports / 1000

      # Pivot the dataframe to make it wide

      exports_table <- dplyr::mutate_(x, exports = ~exports / 1000)
      exports_table <- tidyr::spread_(exports_table, 'year', 'exports')

      # Divide all by 1000
      # Need a way to programmatically call columns from exports_table

      exports_table <- dplyr::mutate_(
        exports_table,
        since_2013 = ~relative_to(`2013`,`2014`, digits = 1),
        since_2010 = ~relative_to(`2010`,`2014`, digits = 1),
        UK_perc = ~100 + relative_to(exports_UK_current, `2014`, digits = 1)
      )

      # Calculate the percentage of UK

      exports_all_sectors_perc <- dplyr::filter_(x, ~sector %in% c('all_sectors', 'UK'))
      exports_all_sectors_perc <- tidyr::spread_(exports_all_sectors_perc, 'sector', 'exports')
      exports_all_sectors_perc <- dplyr::mutate_(exports_all_sectors_perc, perc_of_UK = ~all_sectors/UK)
      exports_all_sectors_perc <- dplyr::select_(exports_all_sectors_perc, ~perc_of_UK, ~year)
      exports_all_sectors_perc <- tidyr::spread_(exports_all_sectors_perc, 'year', 'perc_of_UK')
      exports_all_sectors_perc <- exports_all_sectors_perc * 100
      exports_all_sectors_perc <- cbind(
        sector = 'perc_of_UK',
        exports_all_sectors_perc
      )

      exports_table <- dplyr::bind_rows(
        exports_table,
        exports_all_sectors_perc
      )

      exports_table$sector <- factor(
        exports_table$sector,
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

      exports_table <- dplyr::arrange_(exports_table, ~sector)

      if (html == TRUE) {

        exports_table <- xtable::xtable(
          x = exports_table,
          digits = 1
        )

        print(
          exports_table,
          type = 'html'
        )

      } else {

        print(exports_table)

        }

    },
    warning = function() {

      w <- warnings()
      warning('Warning produced GAV_table():', w)

    },
    error = function(e)  {

      stop('Error produced running exports_table():', e)

    },
    finally = {}
  )
}


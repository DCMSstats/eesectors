#' @title format_table()
#'
#' @description Method to convert table into wide format
#'
#' @details Method to convert table into wide format
#'
#' @param x Object of \code{class(x) == 'long_data'}.
#'
#' @return wide format table
#'
#' @importFrom lazyeval interp
#' @importFrom dplyr filter_ mutate_ select_
#' @export
format_table <- function(x) UseMethod('format_table')
format_table.long_data <- function(x) {

  out <- tryCatch(
    expr = {

      max_year <- max(x$year)
      measure <- x$type

      df_UK <- dplyr::filter_(x$df, ~sector == 'UK')

      # Extract the current UK GVA estimate. Expect to pass 2015 as argument to
      # function n future versions.

      df_current <- dplyr::filter_(x$df, ~year == max_year, ~sector == 'UK')
      df_current <- dplyr::select_(df_current, measure) / 1000

      # Pivot the dataframe to make it wide

      df_wide <- dplyr::mutate_(
        x$df,
        lazyeval::interp(~measure, measure = as.name(measure))
      )
      df_wide <- tidyr::spread_(df_wide, 'year', measure)

      # Divide all by 1000

      df_wide <- dplyr::mutate_(
        df_wide,
        since_2014 = ~relative_to(`2014`,`2015`, digits = 1),
        since_2010 = ~relative_to(`2010`,`2015`, digits = 1),
        UK_perc = ~100 + relative_to(GVA_UK_current, `2015`, digits = 1)
      )

      # # Calculate the percentage of UK
      #
      # GVA_all_sectors_perc <- dplyr::filter_(x, ~sector %in% c('all_sectors', 'UK'))
      # GVA_all_sectors_perc <- tidyr::spread_(GVA_all_sectors_perc, 'sector', 'GVA')
      # GVA_all_sectors_perc <- dplyr::mutate_(GVA_all_sectors_perc, perc_of_UK = ~all_sectors/UK)
      # GVA_all_sectors_perc <- dplyr::select_(GVA_all_sectors_perc, ~perc_of_UK, ~year)
      # GVA_all_sectors_perc <- tidyr::spread_(GVA_all_sectors_perc, 'year', 'perc_of_UK')
      # GVA_all_sectors_perc <- GVA_all_sectors_perc * 100
      # GVA_all_sectors_perc <- cbind(
      #   sector = 'perc_of_UK',
      #   GVA_all_sectors_perc
      # )
      #
      # GVA_table <- dplyr::bind_rows(
      #   GVA_table,
      #   GVA_all_sectors_perc
      # )
      #
      # GVA_table$sector <- factor(
      #   GVA_table$sector,
      #   levels = c(
      #     'Creative Industries',
      #     'Cultural Sector',
      #     'Digital Sector',
      #     'Gambling',
      #     'Sport',
      #     'Telecoms',
      #     'Tourism',
      #     'all_sectors',
      #     'perc_of_UK',
      #     'UK'
      #   )
      # )
      #
      # GVA_table <- dplyr::arrange_(GVA_table, ~sector)
      #
      # if (html == TRUE) {
      #
      #   GVA_table <- xtable::xtable(
      #     x = GVA_table,
      #     digits = 1
      #   )
      #
      #   print(
      #     GVA_table,
      #     type = 'html'
      #   )
      #
      # } else {
      #
      #   print(GVA_table)
      #
      # }
      return(df_wide)

    },
    warning = function() {

      w <- warnings()
      warning('Warning produced GVA_by_sector_table():', w)

    },
    error = function(e)  {

      stop('Error produced running GVA_by_sector_table():', e)

    },
    finally = {

      message('Printing wide table')
    }
  )

  return(out)

}

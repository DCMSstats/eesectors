#' @title format_table()
#'
#' @description Method to convert table into wide format
#'
#' @details Method to convert table into wide format
#'
#' @param x Object of \code{class(x) == 'long_data'}.
#' @param html Should the output be an R \code{data.frame} (and \code{tbl} and
#'   \code{tbl_df}) or as html using \code{xtable}.
#'
#' @return wide format table
#'
#' @export

# Define as a method
format_table <- function(x, html = TRUE) UseMethod('format_table')

# Define the method for the long_data class

format_table.long_data <- function(x, html = TRUE) {

  out <- tryCatch(
    expr = {

      x$sector_levels <- c(
        "Creative Industries",
        "Cultural Sector",
        "Digital Sector",
        "Gambling",
        "Sport",
        "Telecoms",
        "Tourism",
        "all_sectors",
        "perc_of_UK",
        "UK"
      )

      max_year <- max(x$year)
      measure <- x$type

      # Extract stats for the whole of the UK ----

      df_UK <- dplyr::filter_(x$df, ~sector == 'UK')

      # Extract the UK GVA estimate for the current year ----

      total_GVA <- dplyr::filter_(x$df, ~year == max_year, ~sector == 'UK')
      total_GVA <- dplyr::select_(total_GVA, measure)

      # Pivot dataframe ---- Go from long data to wide data, putting year on the
      # top row, with a column for each year.

      df_wide <- dplyr::mutate_(
        x$df,
        lazyeval::interp(~measure, measure = as.name(measure))
      )
      df_wide <- tidyr::spread_(df_wide, 'year', measure)

      # Calculate percentage change columns ----
      # Calculate columns relative to 2010 and 2014. Note that t

      df_wide <- dplyr::mutate_(
        df_wide,
        since_2014 = ~relative_to(`2014`,`2015`, digits = 1),
        since_2010 = ~relative_to(`2010`,`2015`, digits = 1),
        UK_perc = ~100 + relative_to(total_GVA[[1]],`2015`, digits = 1)
      )

      # To avoid headaches later: convert the column names into syntactically
      # valid ones

      names(df_wide) <- make.names(names(df_wide))

      # Calculate the percentage of UK ----

      df_sectors_perc <- dplyr::filter_(x$df, ~sector %in% c('all_sectors', 'UK'))
      df_all_sectors_perc <- tidyr::spread_(df_sectors_perc, 'sector', 'GVA')
      df_all_sectors_perc <- dplyr::mutate_(df_all_sectors_perc, perc_of_UK = ~all_sectors/UK)
      df_all_sectors_perc <- dplyr::select_(df_all_sectors_perc, ~perc_of_UK, ~year)
      df_all_sectors_perc <- tidyr::spread_(df_all_sectors_perc, 'year', 'perc_of_UK')
      df_all_sectors_perc <- df_all_sectors_perc * 100
      df_all_sectors_perc <- data.frame(
        sector = factor('perc_of_UK', levels = x$sector_levels),
        df_all_sectors_perc
      )

      # Normalise the factor levels in df_wide, and

      df_wide <- dplyr::mutate_(df_wide, sector = ~factor(sector, levels = x$sector_levels))

      df_table <- dplyr::bind_rows(
        df_wide,
        df_all_sectors_perc
      )

      # Arrange in the order of the factors

      df_table <- dplyr::arrange_(df_table, ~sector)

      # Format numbers for output using roundf. Better to refer to these columns
      # not by index, but will return to this problem when the method is
      # generalised.


      df_table[,paste0('X', x$years)] <- roundf(df_table[,paste0('X', x$years)])

      # Print to html or as dataframe ----


      if (html == TRUE) {

        df_table <- xtable::xtable(
          x = df_table,
          digits = 1
        )

        print(
          df_table,
          type = 'html'
        )

      } else {

        print(df_table)

      }

    },
    warning = function(w) {

      w <- warnings()
      warning('Warning produced format_table.long_data method:', w)

    },
    error = function(e)  {

      stop('Error produced format_table.long_data method:', e)

    },
    finally = {}
  )

}

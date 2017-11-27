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
year_sector_table <- function(x, html, fmt, ...) UseMethod('year_sector_table')

# Define the method for year_sector_data() class

#' @describeIn year_sector_table Create wide table from year_sector_data() class
#' @export

year_sector_table.year_sector_data <- function(x, html = FALSE, fmt = '%.1f', ...) {

  out <- tryCatch(
    expr = {

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
      since_2015 = ~relative_to(`2015`,`2016`, digits = 10),
      since_2010 = ~relative_to(`2010`,`2016`, digits = 10),
      UK_perc = ~100 + relative_to(total_GVA[[1]],`2016`, digits = 10)
    ) %>%
      mutate(`2010` = `2010` / 1000) %>%
      mutate(`2011` = `2011` / 1000) %>%
      mutate(`2012` = `2012` / 1000) %>%
      mutate(`2013` = `2013` / 1000) %>%
      mutate(`2014` = `2014` / 1000) %>%
      mutate(`2015` = `2015` / 1000) %>%
      mutate(`2016` = `2016` / 1000)


    # To avoid headaches later: convert the column names into syntactically
    # valid ones

    names(df_wide) <- make.names(names(df_wide))

    # Calculate the percentage of UK ----

    df_sectors_perc <- dplyr::filter_(x$df, ~sector %in% c('all_dcms', 'UK'))
    df_all_dcms_perc <- tidyr::spread_(df_sectors_perc, 'sector', 'GVA')
    df_all_dcms_perc <- dplyr::mutate_(df_all_dcms_perc, perc_of_UK = ~all_dcms / UK)
    df_all_dcms_perc <- dplyr::select_(df_all_dcms_perc, ~perc_of_UK, ~year)
    df_all_dcms_perc <- tidyr::spread_(df_all_dcms_perc, 'year', 'perc_of_UK')
    df_all_dcms_perc <- df_all_dcms_perc * 100
    df_all_dcms_perc <- data.frame(
      sector = factor('perc_of_UK', levels = names(x$sectors_set)),
      df_all_dcms_perc
    )

    # Normalise the factor levels in df_wide, and

    df_wide <- dplyr::mutate_(df_wide, sector = ~factor(sector, levels = names(x$sectors_set)))

    df_table <- dplyr::bind_rows(
      df_wide,
      df_all_dcms_perc
    )

    # Arrange in the order of the factors

    df_table <- dplyr::arrange_(df_table, ~sector)


      # Format numbers for output using roundf. Better to refer to these columns
      # not by index, but will return to this problem when the method is
      # generalised.

      # df_table[df_table$sector != 'perc_of_UK', paste0('X', x$years)] <- roundf(df_table[df_table$sector != 'perc_of_UK', paste0('X', x$years)], fmt)
      # df_table[df_table$sector == 'perc_of_UK', paste0('X', x$years)] <- sprintf(fmt, as.numeric(df_table[df_table$sector == 'perc_of_UK', paste0('X', x$years)]))

      # Finally set

      df_table$sector <- factor(unname(x$sectors_set[df_table$sector]))

      # Print to html or as dataframe ----


      if (html == TRUE) {

        df_table <- xtable::xtable(
          x = df_table,
          ...
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
      warning('Warning produced year_sector_table.year_sector_data method:', w)

    },
    error = function(e)  {

      stop('Error produced year_sector_table.year_sector_data method:', e)

    },
    finally = {}
  )

}

#' @title Create Figure 3.1
#'
#' @description Creates Figure 3.1 from
#'   (\url{https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/544103/DCMS_Sectors_Economic_Estimates_-_August_2016.pdf})
#'   using \code{ggplot2}.
#'
#' @details \code{figure3.1} takes as input a standardised long format GVA data
#'   frame, and uses \code{ggplot} and \code{govstyle} to format a pretty(ish) plot.
#' @param ... Passes arguments to \code{ggplot}.
#'
#' @param x Object of class \code{long_table()}.
#'
#' @return Figure 3.1
#'
#' @examples
#'
#' library(eesectors)
#'
#' gva <- long_data(GVA_by_sector_2016)
#' figure3.1(gva)
#'
#' @export

# Define as a method
figure3.1 <- function(x, ...) UseMethod('figure3.1')

# Define the method for long_data() class

#' @describeIn figure3.1 Create plot 3.1
#' @export

figure3.1.long_data <- function(x, ...) {

  out <- tryCatch(
    expr = {

      # Extract the UK GVA

      x <- dplyr::filter_(x$df, ~sector != 'UK')
      x <- dplyr::mutate_(x, year = ~factor(year, levels=c(2016:2010)))

      p <- ggplot2::ggplot(x) +
        ggplot2::aes_(
          y = ~GVA,
          x = ~sector,
          fill = ~year
          ) +
        ggplot2::geom_bar(
          colour = 'slategray',
          position = 'dodge',
          stat = 'identity'
          ) +
        ggplot2::coord_flip() +
        govstyle::theme_gov(base_colour = 'black') +
        ggplot2::scale_fill_brewer(
          palette = 'Blues'
          ) +
        ggplot2::ylab('Gross Value Added (\u00a3bn)') +
        ggplot2::theme(legend.position = 'right') +
        ggplot2::scale_y_continuous(labels = scales::comma)

      return(p)

      },
    warning = function() {

      w <- warnings()
      warning('Warning produced running GVA_plot():', w)

    },
    error = function(e)  {

      stop('Error produced running GVA_plot():', e)

    },
    finally = {}
  )
}

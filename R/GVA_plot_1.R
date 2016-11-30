#' @title Create GVA plot 1
#'
#' @description \code{GVA_plot_1} Creates Figure 3.1 from
#'   (\url{https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/544103/DCMS_Sectors_Economic_Estimates_-_August_2016.pdf})
#'   using \code{ggplot2}.
#'
#' @details \code{GVA_plot_1} takes as input a standardised long format GVA data
#'   frame, and uses \code{ggplot} and \code{govstyle} to format a pretty(ish) plot.
#'
#' @param x Input dataframe.
#'
#' @return Properly formatted GVA table for release.
#'
#' @examples
#'
#' library(EESectors)
#'
#' GVA_plot_1(GVA_by_sector_2016)
#'
#' @importFrom dplyr mutate_ filter_
#' @importFrom tidyr spread
#' @importFrom scales comma
#' @import ggplot2
#' @export

GVA_plot_1 <- function(x) {

  tryCatch(
    expr = {

      # Extract the UK GVA

      x <- dplyr::filter_(x, ~sector != 'UK')
      x <- dplyr::mutate_(x, year = ~factor(year, levels=c(2016:2010)))

      ggplot2::ggplot(x) +
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

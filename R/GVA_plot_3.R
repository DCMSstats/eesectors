#' @title Create GVA plot 3
#'
#' @description \code{GVA_plot_3} Creates Figure 3.2 from
#'   (\url{https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/544103/DCMS_Sectors_Economic_Estimates_-_August_2016.pdf})
#'   using \code{ggplot2}.
#'
#' @details \code{GVA_plot_3} takes as input a standardised long format GVA data
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
#' GVA_plot_3(GVA)
#'
#' @importFrom dplyr mutate_ filter_
#' @importFrom tidyr spread
#' @importFrom scales comma
#' @import ggplot2
#' @export

GVA_plot_3 <- function(x) {

  tryCatch(
    expr = {

      # Calculate the index (2010=100) variable. This code filters out only the
      # all sectors and UK data, and then divides it by the 2010 data

      x <- dplyr::filter_(x, ~!sector %in% c('UK','all_sectors'))
      x <- dplyr::group_by_(x, ~sector)
      x <- dplyr::mutate_(
        x,
        index = ~max(ifelse(year == 2010, GVA, 0)),
        indexGVA = ~GVA/index * 100
        )

      # Create the plot

      ggplot2::ggplot(x) +
        ggplot2::aes_(
          y = ~indexGVA,
          x = ~year,
          colour = ~sector,
          linetype = ~sector
        ) +
        ggplot2::geom_path(
          size = 1.5
          ) +
        govstyle::theme_gov(base_colour = 'black') +
        ggplot2::scale_colour_brewer(palette = 'Set1') +
        ggplot2::ylab('GVA Index: 2010=100') +
        ggplot2::theme(
          legend.position = 'right'
          ) +
        ggplot2::ylim(c(80, 130))

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


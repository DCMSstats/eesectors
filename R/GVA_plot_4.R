#' @title Create GVA plot 4
#'
#' @description \code{GVA_plot_4} Creates Figure 3.4 from
#'   (\url{https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/544103/DCMS_Sectors_Economic_Estimates_-_August_2016.pdf})
#'   using \code{ggplot2}.
#'
#' @details \code{GVA_plot_4} takes as input a standardised long format GVA data
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
#' GVA_plot_4(GVA_by_sector_2016)
#'
#' @export

GVA_plot_4 <- function(x) {

  tryCatch(
    expr = {

      print('GVA_plot_4 not implemented at present')

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


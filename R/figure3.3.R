#' @title Create Figure 3.3
#'
#' @description Creates Figure 3.3 from
#'   (\url{https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/544103/DCMS_Sectors_Economic_Estimates_-_August_2016.pdf})
#'   using \code{ggplot2}.
#'
#' @details \code{figure3.3} takes as input a standardised long format GVA data
#'   frame, and uses \code{ggplot} and \code{govstyle} to format a pretty(ish) plot.
#' @param ... Passes arguments to \code{ggplot}.
#'
#' @param x Object of class \code{long_table()}.
#'
#' @return Figure 3.3
#'
#' @examples
#'
#' library(eesectors)
#'
#' gva <- long_data(GVA_by_sector_2016)
#' figure3.3(gva)
#'
#' @export

# Define as a method
figure3.3 <- function(x, ...) {

  out <- tryCatch(
    expr = {

      sectors_set <- x$sectors_set

      # Calculate the index (2010=100) variable. This code filters out only the
      # all sectors and UK data, and then divides it by the 2010 data

      x <- dplyr::filter_(x$df, ~!sector %in% c('UK','all_dcms'))

      x$sector <- factor(
        x = unname(sectors_set[as.character(x$sector)])
      )

      x <- dplyr::group_by_(x, ~sector)
      x <- dplyr::mutate_(
        x,
        index = ~max(ifelse(year == 2010, GVA, 0)),
        indexGVA = ~GVA/index * 100
      )

      # Create the plot

      p <- ggplot2::ggplot(x) +
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
        ggplot2::ylim(c(80, 150))

      return(p)

      },
    warning = function() {

      w <- warnings()
      warning('Warning produced running figure3.2():', w)

    },
    error = function(e)  {

      stop('Error produced running figure3.2():', e)

    },
    finally = {}
  )
}

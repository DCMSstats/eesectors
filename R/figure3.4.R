#' @title Create Figure 3.4
#'
#' @description Creates Figure 3.4 from
#'   (\url{https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/544103/DCMS_Sectors_Economic_Estimates_-_August_2016.pdf})
#'   using \code{ggplot2}.
#'
#' @details \code{figure3.4} takes as input a standardised long format GVA data
#'   frame, and uses \code{ggplot} and \code{govstyle} to format a pretty(ish) plot.
#' @param ... Passes arguments to \code{ggplot}.
#'
#' @param x Object of class \code{long_table()}.
#'
#' @return Figure 3.4
#'
#' @importFrom stats reorder
#'
#' @examples
#'
#' library(eesectors)
#'
#' gva <- year_sector_data(GVA_by_sector_2016)
#' figure3.4(gva)
#'
#' @export

# Define as a method
figure3.4 <- function(x, ...) {

  out <- tryCatch(
    expr = {

      # Assume plot is for most recent year, could be an argument
      most_recent_year <- max(x$df$year)

      # Preserve pretty factor names
      sectors_set <- x$sectors_set

      # We just need the data frame
      x <- x$df

      # Give sector pretty factor names
      x$sector <- factor(
        x = unname(sectors_set[as.character(x$sector)])
      )

      # Year of interest to plot
      x <- dplyr::filter_(x,
                          ~year == most_recent_year)

      # Create per cent of UK GVA variable
      gva_uk <- dplyr::filter_(x,
                               ~sector == "UK")$GVA

      x <- dplyr::mutate_(x,
                          per_cent_uk_gva = ~(GVA) / gva_uk * 100
                          )

      x <- dplyr::filter_(x, ~!sector %in% "UK")

      # Reorder sectors from high to low
      x$sector <- reorder(x$sector, x$per_cent_uk_gva)


      # Create the plot

      p <- ggplot2::ggplot(x) +
        ggplot2::aes_(
          y = ~per_cent_uk_gva,
          x = ~sector,
          colour = ~sector,
          fill = ~sector
        ) +
        ggplot2::geom_bar(stat = "identity") +
        ggplot2::coord_flip() +
        govstyle::theme_gov(base_colour = 'black') +
        ggplot2::scale_colour_brewer(palette = 'Set1') +
        ggplot2::scale_fill_brewer(palette = 'Set1') +
        ggplot2::xlab("") +
        ggplot2::ylab("Per cent") +
        ggplot2::geom_text(
          ggplot2::aes_(label = ~round(per_cent_uk_gva,
                                     digits = 1)),
                  nudge_y = 2, color = 'black')

      return(p)

    },
    warning = function() {

      w <- warnings()
      warning('Warning produced running figure3.4():', w)

    },
    error = function(e)  {

      stop('Error produced running figure3.4():', e)

    },
    finally = {}
  )
}

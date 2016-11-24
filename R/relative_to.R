#' @title Helper function to calculate relative values
#'
#' @description \code{relative_to} Calculates the percentage difference in
#'   \code{y}, relative to \code{x}
#'
#' @details \code{relative_to} Calculates the percentage difference in
#'   \code{y}, relative to \code{x}
#'
#' @param x base variable.
#' @param y relative variable.
#' @param digits Round output to this many digits.
#'
#' @return Returns the percentage difference of \code{y} relative to \code{x}.

relative_to <- function(x, y, digits = 2) {

  z = (y - x) / x
  z = 100 * z
  z = round(z, digits)

  return(z)

}

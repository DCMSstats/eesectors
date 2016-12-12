#' @title Calculate relative values
#'
#' @description Calculates the percentage difference in
#'   \code{y}, relative to \code{x}
#'
#' @details Calculates the percentage difference in
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

#' @title Prepare values for table
#'
#' @description Prepares values for publication in wide tables by dividing by
#'   1000 and rounding and truncating using \code{sprintf()}. Vectorised to work
#'   on single values, vectors, and data.frames.
#'
#' @param x Value to be transformed.
#' @param fmt Inherits from \code{sprintf()}: the format to be returned.
#'
#' @seealso \code{\link{sprintf}}.
#'
#' @return Tranfsormed variable \code{x}.

roundf <- function(x, fmt = '%.2f') {

  # Vectorise for dataframes

  fmt_value <- function(y, fmt) {

    if (is.numeric(y)) {
      y <- y / 1000
      y <- sprintf(fmt, y)
    }

    return(y)

  }

  if (is.data.frame(x)) {

    x <- mapply(function(z) fmt_value(z, fmt = fmt), x)
    x <- dplyr::as_data_frame(x)

  } else if(is.vector(x)|is.numeric(x)) {

    x <- fmt_value(x, fmt = fmt)

  }

  return(x)
}

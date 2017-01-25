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

roundf <- function(x, fmt = '%.1f') {

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

#' @title Check success of type conversion: character to numeric
#'
#' @description Checks which values will convert to \code{NA} when converting a
#'   vector from \code{character} to \code{numeric} or \code{integer}.
#'
#' @details The spreadsheets which come from the Office for National Statistics
#'   (ONS) often contain characters within what should be purely numeric fields.
#'   When we convert these to numeric these will be converted to \code{NA}, but
#'   it is not entirely clear after the fact which values have been converted or
#'   why. This function checks in advance which values will be converted to
#'   \code{NA} so we can confirm that it is nothing to worry about.
#'
#' @param x vector of \code{length(x) > 1} and of nominally of
#'   \code{is.character(x) == TRUE}.
#' @return Returns a list of the entries which created an NA during type
#'   conversion.

integrity_check <- function(x) {

  # Check for issues when converting from character into integer following load
  # from a spreadsheet

  # Which are already NA before conversion?

  NA_before <- !is.na(x)

  # Which are only NA after conversion?

  NA_after <- suppressWarnings(is.na(as.numeric(x)))

  # Create a vector of the offending lines

  conversion_issues <- NA_before & NA_after

  if (length(conversion_issues) > 0 ) {

    warning('WARNING: produced by the integrity_check() function (usually called in the extract_ABS_data.R script).
            Unmatched NAs created when coercing x to to numeric in integrity_check().
            Returning values that caused this error:
            ',
            x[conversion_issues],
            '.
            If the values returned above are full stops or other characters,
            i.e. anything but real numbers, then you can safely ignore this warning.')

    return(conversion_issues)

  } else message('No conversion issues detected.')


}

#' @title Clean SIC codes
#'
#' @description Converts 3 or 4 digit SIC codes from format \code{123} or
#'   \code{1234} into \code{12.3} and \code{12.34} respectively. Codes with
#'   length of 2 or greater than 4 are ignored, and returned as is.
#'
#' @param x A character vector of SIC codes.
#'
#' @return A cleaned character vector of SIC codes.

clean_sic <- function(x) {

  correct_sic <- function(y) {
    if (nchar(y) %in% 3:4) {

      left <- substr(y, 1, 2)
      right <- substr(y, 3, nchar(y))
      y <- paste0(left, '.', right)

    } else return(y)
  }

  x <- unlist(lapply(x, correct_sic))
  return(x)

}

#' @title Find NAs in dataframe columns
#'
#' @description Looks through a \code{data.frame} and returns a character vector
#'   of column names corresponding to columns which contain \code{NA}.
#'
#' @param df A dataframe.
#'
#' @return characvter vector containing the names of columns which contain \code{NA}.

na_cols <- function(df) {


  contains_NA <- apply(df, MARGIN = 2, FUN = anyNA)
  contains_NA <-  colnames(df)[contains_NA]
  return(contains_NA)
}

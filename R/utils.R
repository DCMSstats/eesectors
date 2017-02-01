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
#'   IT WILL ONLY RAISE A WARNING IF: there are new NAs, and any of these NAs,
#'   can cleanly be converted to numeric (wihtout turning to \code{NA}) - i.e.
#'   they are actually numbers, and not characters, which is what we would
#'   expect.
#'
#' @param x vector of \code{length(x) > 1} and of nominally of
#'   \code{is.character(x) == TRUE}.
#' @return Returns the \code{conversion_issues} vector, with following
#'   attribites: \code{length(x) == length(conversion_issues)} and
#'   \code{is.logical(conversion_issues) == TRUE}.
#' @export

integrity_check <- function(x) {

  # Check for issues when converting from character into integer following load
  # from a spreadsheet

  # Which are already NA before conversion?

  NA_before <- !is.na(x)

  # Which are only NA after conversion?

  NA_after <- suppressWarnings(is.na(as.numeric(x)))

  # Create a vector of the offending lines

  conversion_issues <- NA_before & NA_after

  # Check that there are actually some issues

  if (sum(conversion_issues) > 0) {

    # Can these issues be cleanly converted to numeric? If so they are numeric,
    # and this is a problem, as they should not be creating NAs during the
    # original type conversion, hence raise a warning.

    numeric_attempt <- suppressWarnings(as.numeric(x[conversion_issues]))
    numeric_attempt <- all(!is.na(numeric_attempt))

    if (numeric_attempt) {

      warning('WARNING: produced by the integrity_check() function (usually called in the extract_ABS_data.R script).
            Unmatched NAs created when coercing x to to numeric in integrity_check().
            Returning values that caused this error:
            ',
              x[conversion_issues],
              '.
            If the values returned above are full stops or other characters,
            i.e. anything but real numbers, then you can safely ignore this warning.')

    }

  }

  # Whatever happens, return a logical vector corresponding to values of x where
  # conversions from character to numeric resulted in NA

  return(conversion_issues)

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
#' @export

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
#' @return Character vector containing the names of columns which contain \code{NA}.
#' @export

na_cols <- function(df) {

  contains_NA <- apply(df, MARGIN = 2, FUN = anyNA)
  contains_NA <-  colnames(df)[contains_NA]
  return(contains_NA)

}

#' @title Save and check Rds files
#'
#' @description Saves a dataframe \code{x} to an Rds file, checks that the file
#'   was produced, and raises a warning if it was not.
#'
#' @param x Input dataframe.
#' @param full_path Path to which Rds file will be saved.
#'
#' @return Returns nothing
#' @export

save_rds <- function(x, full_path) {

  saveRDS(x, full_path)

  if (file.exists(full_path)) {

    message('Saved to ', full_path)
    message('File is ', file.info(full_path)$size, ' bytes')

  } else warning(full_path, 'was not created.')

}

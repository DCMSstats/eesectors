#' @title maha check
#'
#' @description \code{maha_check} is a function that runs the mahalanobis check
#'
#' @details this is based on \code{assertr::insist_rows} and implements a
#'   malahanobis distance check using \code{assertr:maha_dist}.
#'
#' @param x Input dataframe, see details.
#'
#' @return If the class is instantiated correctly, nothing is returned.
#'

maha_check = function(x) {

  # Note that this test will fail on GVA_by_sector_2016 if x < 6 for
  # within_n_mads(x)

  # This function is called within year_sector_data
  # We inherit the flog threshold and where to append to from there
  futile.logger::flog.trace(msg = "Checking sector timeseries: %s",
                            as.character(unique(x[['sector']])),
                            capture = FALSE)


  assertr::insist_rows(
    as.data.frame(x),
    assertr::maha_dist,
    assertr::within_n_mads(6),
    1:3,
    error_fun = eesectors::raise_issue
  )
}

#' @title Downloads the latest version of the gva_combine.Rmd notebook
#'
#' @description Downloads the latest version of the gva_combine.Rmd notebook,
#'   which is stored within the package at \code{inst/gva_combine.Rmd}.
#'
#' @details   Since combining the various datasets is quite a complex operation
#'   that could easily be disrupted by small changes to the input spreadhseet,
#'   it may be easier to run the combine operation within an R notebook. This
#'   function uses the \code{httr} package to download the latest version of the
#'   notebook from the master branch of the
#'   \url{https://github.com/ukgovdatascience/eesectors} repository.
#'
#' @param url An alternate url for the \code{gva_combine.Rmd} notebook.
#' @param file Local file where the downloaded \code{gva_combine.Rmd} will be
#'   stored.
#'
#' @return The function returns nothing, but saves output to the location
#'   specified by the \code{file} argument.
#'
#' @examples
#'
#' \dontrun{
#' library(eesectors)
#' get_gva_combine()
#' }
#'
#' @export

get_gva_combine = function(url = NULL,file = 'gva_combine.Rmd') {

  # Check whether a url has been passed to url, if not, default to the below

  if (is.null(url)) {

    url <- httr::modify_url(
      url = 'https://raw.githubusercontent.com/',
      path = 'ukgovdatascience/eesectors/master/inst/gva_combine.Rmd'
    )

  }

  message('Fetching ', url)

  resp <- httr::GET(url)

  if (httr::http_type(resp) != "text/plain") {
    stop("Failed to return gva_combine.Rmd in tesxt/plain format", call. = FALSE)
  }

  parsed <- httr::content(resp, "text")
  cat(parsed, file = file)

  if (!file.exists(file)) {
    stop('Failed to create ', file)
  }

  message('File downloaded to ', file)
}

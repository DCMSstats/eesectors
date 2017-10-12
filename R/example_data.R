#' Get path to example_working_file.xlsx example
#'
#' eesectors comes bundled with an example file in its `inst/extdata`
#' directory. This function returns its path.
#'
#' @param path Name of file. If `NULL`, the example files will be listed.
#' @export
#' @examples
#' example_working_file()
#' example_working_file("example_working_file.xlsx")
example_working_file <- function(path = NULL) {
  if (is.null(path)) {
    dir(system.file("extdata", package = "eesectors"))
  } else {
    system.file("extdata", path, package = "eesectors", mustWork = TRUE)
  }
}

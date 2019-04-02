#' Two-way Duplicates
#' @param x a vector, data frame, array, or \code{NULL}
#' @return A logical object of the same dimensions as \code{x}
#' @author Sven Halvorson
#' @examples
#' x = c(1:4, 1, 2, NA)
#' dupes(x)
#' @export
dupes = function(x){
  duplicated(x) | duplicated(x, fromLast = TRUE)
}

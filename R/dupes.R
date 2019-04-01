#' Two-way Duplicates
#' @return A logical object of the same dimensions as \code{x}
#' @author Sven Halvorson
dupes = function(x){

  #' @param x a vector, data frame, array, or \code{NULL}
  duplicated(x) | duplicated(x, fromLast = TRUE)
}

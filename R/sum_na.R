#' Sum Missing Values
#' @author Sven Halvorson
#' @examples
#' sum_na(c(1, NA, 2, NA, 3, NA))
#' @export

sum_na = function(x){
  #' @param x a vector, matrix, or data.frame
  sum(is.na(x))
}


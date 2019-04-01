#' Sum Missing Values
#' @author Sven Halvorson

sum_na = function(x){
  #' @param x a vector, matrix, or data.frame
  sum(is.na(x))
}


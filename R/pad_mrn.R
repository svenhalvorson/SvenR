#' Pad MRNs
#' @description adds leading zeroes to numeric vector
#' @author Sven Halvorson
pad_mrn = function(x){

  #' @param x atomic vector
  library("stringr")
  # Brief little check just to catch myself
  if(any(!is.atomic(x),
         length(x) == 0,
         suppressWarnings(mean(nchar(x[!is.na(x)]))) <= 5)){
    stop("x must be an atomic vector with length > 0 & avg # of characters > 5")
  }

  str_pad(string = x, width = 8, side = "left", pad = "0")

}

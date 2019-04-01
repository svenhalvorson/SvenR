#' Round Percents
#' @description Rounds 100*x, formats to desired number of digits

round_per = function(x, digits = 1){
  #' @param x A numeric vector
  #' @param digist The number of digits to round to 
  x %>% 
    round(digits = digits) %>% 
    format(nsmall = 1)
  
}
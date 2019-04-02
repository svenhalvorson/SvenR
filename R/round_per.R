#' Round Percents
#' @description Rounds 100*x, formats to desired number of digits
#' @param x A numeric vector
#' @param digits The number of digits to round to
#' @examples
#' round_per(c(0.5, 0.6789, 1.0241))
#' @export

round_per = function(x, digits = 1){

  (x*100) %>%
    round(digits = digits) %>%
    format(nsmall = 1)

}

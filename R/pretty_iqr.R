#' Pretty IQR
#' @description Formatted character version of median, Q1, Q3
#' @param x Numeric vector
#' @param digits Digits to round to
#' @param na.rm Remove NA values?
#' @author Sven Halvorson
#' @examples
#' pretty_iqr(mtcars$mpg)
#' @export

pretty_iqr = function(x, digits = 1, na.rm = TRUE){

  # compute median and quantile
  med = round(x = median(x = x, na.rm = na.rm),
              digits = digits)
  quant = round(x = quantile(x = x, probs = c(0.25, 0.75), na.rm = na.rm),
                digits = digits)
  paste0(med, ' [', paste(quant, collapse = ','), ']')

}

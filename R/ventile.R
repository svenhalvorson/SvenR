#' Ventile (5-tiles)
#' @description Compute 5th, 10th, 15th ... percentiles
#' @param x a numeric vector
#' @param quiet should it print observation count and missing rate?
#'
#' @return a numeric vector of 19 quantiles
#' @export
#' @author Sven Halvorson
#' @examples
#' ventile(
#'   x = sample(
#'     x = c(1:100, NA_real_),
#'     replace = TRUE,
#'     size = 1234,
#'     prob = 1:101
#'   ),
#'   quiet = FALSE
#' )

ventile = function(
  x,
  quiet = TRUE
){
  # Check appropriate input
  if(
    !all(
      is.numeric(x),
      is.vector(x)
    )
  ){
      stop('x must be a numeric vector')
  }

  # If we wanna be squawkey
  if(!quiet){
    cat(
      paste0(
        '\n\n',
        format(length(x), big.mark = ','),
        ' observations given\n\n ',
        format(sum(is.na(x)), big.mark = ','),
        ' (',
        round_per(mean(is.na(x))),
        '%) missing\n\n'
      )
    )
  }

  quantile(
    x = x,
    probs = 1:19/20,
    na.rm = TRUE
  )

}

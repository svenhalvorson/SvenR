#' Convert labelled numerics to character
#'
#' @param x a labelled numeric
#'
#' @return a character vector
#' @export
#' @author Sven Halvorson (svenpubmail@gmail.com)
#' @examples
#' labelled_num = sample(1:3, size = 10, replace = TRUE)
#' expss::val_lab(labelled_num) = c(
#'   'Tyre' = 1,
#'   'Byblos' = 2,
#'   'Ugarit' = 3
#' )
#' table(
#'   labelled_num,
#'   labelled_to_character(labelled_num)
#' )
#'
labelled_to_character = function(x){

  if(
    !all(
      is.numeric(x),
      'labels' %in% names(attributes(x))
    )
  ){
    stop('x must be an numeric with value labels')
  }

  labs = attr(x, 'labels')

  names(labs)[match(x, labs)]

}



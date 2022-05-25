#' Convert labelled numerics to factors
#'
#' @param x an atomic numeric with the attribute "labels". Probably from \code{expss::val_lab}
#' @return a factor
#' @note This is a bit of a quirky solution because the integers underlying
#' a factor are default set to 1 through the number of unique items. This means
#' that without saving the original value labels
#' @export
#' @author Sven Halvorson (svenpubmail@gmail.com)
#' @examples
#' city_labels = c(
#'   'Urruk' = 2,
#'   'Babylon' = 3,
#'   'Larsa' = 4,
#'   'Mari' = 5
#' )
#'
#' set.seed(0)
#' cities = sample(2:5, size = 10, replace = TRUE)
#'
#' expss::val_lab(cities) = city_labels
#'
#' labelled_to_factor(cities)
#'
#' # NOTE the difference:
#' as.numeric(labelled_to_factor(cities)) == cities

labelled_to_factor = function(x){

  if(
    any(
      !'labels' %in% names(attributes(x)),
      !is.atomic(x),
      !is.numeric(x)
    )
  ){
    stop('x must be an atomic numeric vector with the attribute "labels"')
  }

  char_vals = as.character(x)
  val_labs = attr(x, 'labels')

  output = factor(
    x = char_vals,
    levels = names(val_labs)
  )

  # TODO: decide if we want to keep this line. It's nice to make it reversible
  attr(output, 'original_labels') = val_labs

  output
}


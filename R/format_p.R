#' Format p-values
#' @description Create rounded, character versions of p-values for presentation
#' @param p A numeric vector of p-values to be formatted
#' @param min_digits The minimum number of digits to display
#' @param max_digits The maximum number of digits to display for a small p-value
#' @param level Significance level tested at
#' @return An atomic character vector
#' @details The goal of this function is to round P values for tables or text.
#' If rounding a p value to \code{min_digits} is not 0, 1, or the significance level, that is returned.
#' Values rounded to 1 or the significance level will be iteratively rounded to another digit until a distinct value is returned.
#' Values near zero will be iteratively rounded until reaching a nonzero value or reaching \code{max_digits}.
#' Remaining values are labeled as 'P < 0.00...1'
#' @export
#' @author Sven Halvorson
#' @examples
#' p_vals = c(0.6963, 0.00007, 0.0247, 0.0253, 0.999964)
#'
#' format_p(
#'   p = p_vals,
#'   min_digits = 3,
#'   max_digits = 4,
#'   level = 0.025
#' )

format_p = function(
  p,
  min_digits = 2,
  max_digits = 3,
  level = 0.05
){

  # Checks:
  if(
    any(
      !is.numeric(p),
      !is.vector(p)
    )
  ){
    stop('p must be a numeric vector')
  }
  if(
    any(
      !is.numeric(level),
      length(level) != 1,
      level >= 1,
      level <= 0
    )
  ){
    stop('level must be in (0, 1)')
  }

  # small function to round each p-value:
  round_p = function(p){

    round_p = round(p, min_digits)
    # If we have a value over level:
    if(round_p != level & round_p %nin% c(0,1)){
      format(
        round_p,
        nsmall = min_digits
      )
    }
    # If we have exactly the same p as significance level (unlikely):
    else if(p == level){
      return(level)
    }
    # If we round to the significance level, keep moving out
    # until we get something different:
    else if(round(p, min_digits) == level){
      i = 0
      while(round(p, min_digits + i) == level){
        i = i + 1
      }
      format(
        round(p, min_digits + i),
        nsmall = min_digits + i
      )
    # IF we got zero, report the min digits
    } else if(round_p == 0){
      if(p < 10^(-max_digits)){
        paste0(
          'P < 0.',
          paste0(
            rep('0', times = max_digits - 1),
            collapse = ''
          ),
          '1'
        )
      } else{
        format(
          round(p, max_digits),
          nsmall = max_digits
        )
      }

    }
    # Last case is p near 1:
    else{
      i = 0
      while(round(p, max_digits + i) == 1){
        i = i + 1
      }
      format(
        round(p, max_digits + i),
        nsmall = max_digits + i
      )
    }
  }

  # now apply to the whole vector:
  vapply(
    X = p,
    FUN = round_p,
    FUN.VALUE = character(1)
  )

}


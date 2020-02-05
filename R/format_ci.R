#' Format Confidence Intervals
#' @description Round and format confidence intervals for presentation.
#' @param point, lower, upper The point estimate, lower bound, and upper bound.
#' @param digits A vector of digits to begin rounding at.
#' @param max_its The maximum number of additiona digits to give
#' @param null_value A vector of null values to be compared to.
#' @details The goal of this function is to round confidence intervals
#' for presentation. You can supply digits to round to or let the function guess.
#' It will try to improve the CI until it hits the \code{max_its}. The function
#' attempts to have the point estimate and each end of the CI as different numbers.
#' If you supply a \code{null_value} it will try not to use that as either endpoint
#' and keep the null value on the same side of the CI as the unformatted value is.
#' If \code{unacceptables} is supplied, these values will not be allowed as
#' endpoints for the CI.
#' @author Sven Halvorson
#' @export format_ci

format_ci = function(
  point,
  lower,
  upper,
  null_value = NA,
  digits = NA,
  max_its = 4,
  unacceptables = NA
){

  # First thing is to do the checks

  # All CI arguments must be numeric:
  num_vec = function(x){
    is.numeric(x) & is.vector(x)
  }
  if(
    any(
      !num_vec(point),
      !num_vec(lower),
      !num_vec(upper)
    )
  ){
    stop('point, lower, and upper must be numeric')
  }

  cis = Map(
    f = round_ci,
    point = point,
    lower = lower,
    upper = upper,
    digits = digits,
    null_value = null_value,
    max_its = max_its,
    unacceptables = unacceptables

  )
  cis %>%
    dplyr::bind_rows()

}


round_ci =  function(point, lower, upper,
                     digits, null_value,
                     max_its = 4, unacceptables){

  # Are we testing against a null value?
  if(!missing(null_value)){
    if(!is.na(null_value)){
      has_null = TRUE
    }
  } else{
    has_null = FALSE
  }

  # Are we guessing the digit range?
  if(missing(digits)){
    digits = choose_digits(lower, upper)
  }
  if(is.na(digits)){
    digits = choose_digits(lower, upper)
  }

  # Are we excluding certain values?
  if(!missing(unacceptables)){
    if(!is.na(unacceptables)){
      has_unacceptables = TRUE
    }
  } else{
    has_unacceptables = FALSE
  }

  # Flag for when the loop is complete and we're off to the races!
  done = 0
  while(done == 0){

    # Tick down the maximum iterations it will try
    max_its = max_its - 1
    if(max_its == -1){
      warning('Maximum iterations reached')
      done = 1
    }

    vals = vapply(
      X = c(point, lower, upper),
      FUN = round,
      FUN.VALUE = numeric(1),
      digits = digits
    )

    # Check if they're all different
    if(length(unique(vals)) < length(vals)){
      digits = digits + 1
      next()
    }

    # Now we check if the null value's order preserved after rounding:
    if(has_null){
      if(
        any(
          vals[2] == null_value,
          vals[3] == null_value,
          (lower - null_value < 0) != (vals[2] - null_value < 0),
          (upper - null_value < 0) != (vals[3] - null_value < 0)
        )
      ){
        digits = digits + 1
        next()
      }
    }

    # Check if the unacceptable values are in the values:
    if(has_unacceptables){
      if(sum(unacceptables %in% vals) > 0){
        digits = digits + 1
        next()
      }
    }

    done = 1

  }

  # Format them to strings:
  vals = format(vals, nsmall = digits, scientific = FALSE)

  tibble(
    point = vals[1],
    lower = vals[2],
    upper = vals[3]
  ) %>%
    mutate(
      CI = paste0(point, ' (', lower, ', ', upper, ')')
    )

}


choose_digits = function(lower, upper){

  # Use this little doohickey to selet the appropriate starting digits
  # if the user doesn't supply them for one or more intervals:

  if(lower >= upper){
    stop('Lower and upper bounds must be properly ordered')
  }

  # First thing is to see how far apart the lower and upper bound are in log:
  logdiff = log10(upper - lower)

  # now we go through some cases:
  if(logdiff < 0){
    max(
      c(
        ceiling(-1*logdiff),
        2
      )
    )

  }
  else if(logdiff < 1){
    1
  }
  else{
    0
  }

}

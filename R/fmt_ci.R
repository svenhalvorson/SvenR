#' Format CIs
#' @description Round and format confidence intervals
#' @param point, lower, upper The point estimate, lower bound, and upper bound.
#' @param digits A vector of digits to begin rounding at.
#' @param max_its The maximum number of additiona digits to give
#' @param null_value A vector of null values to be compared to. If

#' @details H
#' @author Sven Halvorson
#' @examples
#' @export fmt_ci

fmt_ci = function(
  point,
  lower,
  upper,
  null_value,
  digits,
  max_its = 4
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
    .f = round_ci,
    point = point,
    lower = lower,
    upper = upper,
    digits = digits,
    null_value = null_value

  )

}


round_ci =  function(point, lower, upper,
                     digits, null_value){

  # Are we testing against a null value?
  has_null = !missing(null_value) & !is.na(null_value)

  # Are we guessing the digit range?
  if(missing(digits) | is.na(digits)){
    digits = choose_digits(lower, upper)
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
      X = c(point, lower, ub),
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
          vars[2] == null_value,
          vars[3] == null_value,
          (lower - null_value < 0) != (vars[2] - null_value < 0),
          (upper - null_value < 0) != (vars[3] - null_value < 0)
        )
      ){
        digits = digits + 1
        next()
      }
    }
    done = 1

  }

  tibble(
    point = vals[1],
    lower = vals[2],
    upper = vals[3]
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
    ceiling(-1*logdiff)
  }
  else if(logdiff < 1){
    1
  }
  else{
    0
  }

}
x1 = 100.203
x2 = 100.210

ceiling(-1*log10(x2-x1))

y2 = 100.203
y1 = 88.429

ceiling(-1*log10(y2-y1))

z2 = 100.203
z1 = 98.429

ceiling(-1*log10(z2-z1))

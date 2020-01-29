#' Format CIs
#' @description Round and format confidence intervals
#' @param estimate, lower, upper The point estimate, lower bound, and upper bound.
#' @param digits A vector of digits to begin rounding at.
#' @param max_its The maximum number of additiona digits to give
#' @param null_value A vector of null values to be compared to. If

#' @details
#' @author Sven Halvorson
#' @examples
#' @export fmt_ci

round_ci =  function(estimate, lower, upper,
                     digits = 2, max_its = 4,
                     null_value){

  # Are we testing against a null value?
  has_null = !missing(null_value) & !is.na(null_value)


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
      X = c(estimate, lower, ub),
      FUN = round,
      FUN.VALUE = numeric(1),
      digits = digits
      )

    # If we don't want to adjust any further:
    if(strict){
      done = 1
    }

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

  vals

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

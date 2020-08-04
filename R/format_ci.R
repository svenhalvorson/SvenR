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
#' @examples
#' # Set up a dataset for a logistic regression model:
#' df = nycflights13::flights %>%
#'   mutate(on_time = dep_delay <= 0)
#'
#' analysis_table = glm(
#'   formula = on_time ~ month + sched_dep_time + origin + air_time,
#'   data = df,
#'   family = binomial
#' ) %>%
#'   broom::tidy(
#'     conf.int = TRUE
#'   )
#'
#' cis = format_ci(
#'   point = analysis_table['estimate'],
#'   lower = analysis_table['conf.low'],
#'   upper = analysis_table['conf.high'],
#'   null_value = 1,
#'   unacceptables = 0
#' )
#'
#' analysis_table %>%
#'   select(
#'     term,
#'     estimate,
#'     conf.low,
#'     conf.high
#'   ) %>%
#'   bind_cols(cis)
#'
#' @author Sven Halvorson
#' @export format_ci

format_ci = function(
  point,
  lower,
  upper,
  null_value = NA_real_,
  digits = NA_real_,
  max_its = 4,
  unacceptables = NA_real_
){
  
  # First thing is to do the checks
  if(
    any(
      missing(point),
      missing(lower),
      missing(upper)
    )
  ){
    warning('missing values for point, lower, or upper supplied')
  }
  # All CI arguments must be numeric atomics:
  point = unlist(point)
  lower = unlist(lower)
  upper = unlist(upper)

  num_vec = function(x){
    is.numeric(x) & is.vector(x) & is.atomic(x)
  }
  if(
    any(
      !num_vec(point),
      !num_vec(lower),
      !num_vec(upper),
      length(point) != length(upper),
      length(point) != length(lower),
      length(upper) != length(lower)
    )
  ){
    stop('point, lower, and upper must be numeric vectors of the same length')
  }

  # Check the other arguments:
  check_arg = function(x){

    x = get(x, envir = parent.frame())
    max(
      c(
        missing(x),
        num_vec(x) & length(x) %in% c(1, length(point)),
        is.na(x) & length(x) == 1
      )
    )

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
    dplyr::bind_rows() %>%
    dplyr::mutate(
      CI = dplyr::case_when(
        is.na(point) | is.na(lower) | is.na(upper) ~ NA_character_,
        TRUE ~ paste0(point, ' (', lower, ', ', upper, ')')
      )
    )

}


round_ci =  function(point, lower, upper,
                     digits, null_value,
                     max_its = 4, unacceptables){
  
  # If missing any:
  if(
    any(
      is.na(point),
      is.na(lower),
      is.na(upper)
    )
  ){
    return(
      tibble::tibble(
        point = NA_character_,
        lower = NA_character_,
        upper = NA_character_
      ) 
    )
  }
  
  
  # Are we testing against a null value?
  if(!missing(null_value)){
    if(!is.na(null_value)){
      has_null = TRUE
    } else{
      has_null = FALSE
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
    } else{
      has_unacceptables = FALSE
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
          sum(vals == null_value) > 0,
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
  )

}


choose_digits = function(lower, upper){

  # Use this little doohickey to select the appropriate starting digits
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



#' Fill Down
#' @description Fill missing value with most recent non-missing value
#' @author Sven Halvorson
#' @examples
#' NM = c(NA, 'Ruidosa', NA, '', NA, 'Corona', NA, 'Roswell')
#' fill_down(NM)
#' fill_down(NM, empty_string = TRUE)
#' fill_down(NM, reverse = TRUE)
#' @export

fill_down <- function(x, empty_string = FALSE, reverse = FALSE){
  #' @param x An atomic vector
  #' @param empty_string Should empty strings be treated as NA?


  if(!is.atomic(x) | !is.vector(x)){
    stop("x must be an atomic vector")
  }

  # Can define this function to determine if empty strings count
  if(empty_string){
    check_mia <- function(y){
      is.na(y) | y == ''
    }
  }else{
    check_mia <- function(y){
      is.na(y)
    }
  }
  # reverse?
  if(reverse){
    x = rev(x)
  }

  # Store the most recent non NA value and loop through the vector
  temp = NA
  for(i in 1:length(x)){

    # First case is the vector starts with NA(s), just keep going
    if(is.na(temp) & check_mia(x[i])){
      # case in which empty strings precede a the first non-empty string
      if(empty_string){
        x[i] = NA
      }
      next()
    }

    # If we hit a real value, save it
    if(!check_mia(x[i])){
      temp = x[i]
      next()
    }

    # Finally, if we have a value stored and x[i] is NA
    if(!is.na(temp) & check_mia(x[i])){
      x[i] = temp
    }
  }
  # reverse back
  if(reverse){
    x = rev(x)
  }


  return(x)
}



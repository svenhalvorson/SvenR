#' Column Missing Counts
#' @description Count missing values by column
#' @note Likely to be used interactively
#' @author Sven Halvorson
col_miss = function(df, empty_string = FALSE){
  #' @param df A data frame
  #' @param empty_string Should only white space values be treated as NA?

  # Always use protection:
  if(!is.data.frame(df) |
     nrow(df) == 0){
    stop('df must be a data frame with at least one row')
  }
  if(!empty_string %in% c(TRUE, FALSE) |
     length(empty_string) != 1){
    stop('empty_string must be either TRUE or FALSE')
  }

  # if we want to check missing character values:
  if(empty_string){
    check_na = function(x){
      if(is.character(x)){
        sum(is.na(x) | trimws(x) == '')
      }
      else{
        sum_na(x)
      }
    }
  }
  else{
    check_na = sum_na
  }

  vapply(X = df, FUN = check_na, FUN.VALUE = integer(1))

}

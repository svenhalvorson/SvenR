#' Column Missing Percent
#' @description Percent of values missing by column
#' @param df A data frame
#' @param empty_string Should only white space values be treated as NA?
#' @note Likely to be used interactively
#' @author Sven Halvorson
#' @examples
#' set.seed(1)
#' dat = c('X', 'Y', 'Z', '', NA)
#' df = tibble::tibble(a = sample(dat, size = 5, replace = TRUE),
#'                     b = sample(dat, size = 5, replace = TRUE),
#'                     c = sample(dat, size = 5, replace = TRUE))
#' df
#' col_miss(df)
#' col_miss(df, empty_string = TRUE)
#' @export
col_miss = function(df, empty_string = FALSE){

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
        round_per(sum(is.na(x) | trimws(x) == '')/length(x))
      }
      else{
        round_per(mean(is.na(x)))
      }
    }
  }
  else{
    check_na = function(x){
      round_per(mean(is.na(x)))
    }
  }

  vapply(X = df, FUN = check_na, FUN.VALUE = character(1)) %>%
    paste0('%')

}

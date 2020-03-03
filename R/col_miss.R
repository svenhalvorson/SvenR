#' Column Missing Percent
#' @description Percent of values missing by column
#' @param df A data frame
#' @param empty_string Should only white space values be treated as NA?
#' @param numeric_out Should the return value be unformatted numbers?
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
col_miss = function(
  df,
  empty_string = FALSE,
  numeric_out = FALSE){

  # Capture data frame name:
  df_name = dplyr::enquo(df) %>%
    (dplyr::quo_name)

  # Always use protection:
  if(!is.data.frame(df) |
     nrow(df) == 0){
    stop('df must be a data frame with at least one row')
  }
  if(!empty_string %in% c(TRUE, FALSE) |
     length(empty_string) != 1){
    stop('empty_string must be either TRUE or FALSE')
  }

  # Depending on whether we want formatted output:
  round_fun = ifelse(
    numeric_out,
    identity,
    round_per
  )

  # if we want to check missing character values:
  if(empty_string){
    check_na = function(x){
      if(is.character(x)){
        round_fun(sum(is.na(x) | trimws(x) == '')/length(x))
      }
      else{
        round_fun(mean(is.na(x)))
      }
    }
  }
  else{
    check_na = function(x){
      round_fun(mean(is.na(x)))
    }
  }
  cat(paste('Percent missing by column for', df_name,':\n\n'))
  if(numeric_out){
    vapply(
      X = df,
      FUN = check_na,
      FUN.VALUE = numeric(1)
    )
  }
  else{
    vapply(
      X = df,
      FUN = function(x){paste0(check_na(x),'%') },
      FUN.VALUE = character(1)
    )
  }

}

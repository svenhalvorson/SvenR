#' Find Columns
#' @description  Find columns in a data frame by regular expression
#' @author Sven Halvorson

find_cols = function(df, pattern, value = TRUE, ignore.case = TRUE){

  #' @param df A data frame
  #' @param pattern A regular expression
  #' @param value Should the column names or positions be returned?
  #' @param ignore.case Should case be ignored in regular expression matching?
  #' @note This is mostly for interactive use

  if(!is.data.frame(df)){
    stop('df must be a data.frame')
  }
  if(!all(is.character(pattern),
          is.vector(pattern),
          length(pattern) == 1)){
    stop('pattern must be an atomic character of length 1')
  }

  grep(pattern = pattern, x = colnames(df), ignore.case = ignore.case, value = value)
}






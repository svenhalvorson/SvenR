#' Find Columns
#' @description  Find columns in a data frame by regular expression
#' @author Sven Halvorson
#' @examples
#' find_cols(mtcars, ar, pg)
#' find_cols(mtcars, 'ar', value = FALSE)
#' @export

find_cols = function(df, ..., value = TRUE, ignore.case = TRUE){

  #' @param df A data frame
  #' @param ... Regular expressions, quoted or not
  #' @param value Should the column names or positions be returned?
  #' @param ignore.case Should case be ignored in regular expression matching?
  #' @note This is mostly for interactive use

  if(!is.data.frame(df)){
    stop('df must be a data.frame')
  }
  # Capture the input, fix if supplied quoted strings
  arguments = enquos(...) %>%
    map_chr(quo_name)
  # if the user supplied a character vector, clean it up:
  if(length(arguments) == 1){
    if(str_detect(string = arguments, pattern = 'c\\(')){
      arguments = arguments %>%
        str_remove_all('c\\(|\\)|\"') %>%
        str_split(pattern = ', ', simplify = TRUE) %>%
        .[1,]}
  }
  arguments %>%
    map(.f = grep,
            x = colnames(df),
            ignore.case = ignore.case,
            value = value) %>%
    unlist %>%
    unique %>%
    sort


}






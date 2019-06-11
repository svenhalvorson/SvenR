#' Find Columns
#' @description  Find columns in a data frame by regular expression
#' @param df A data frame
#' @param ... Keys to search for. Regular expressions must be qutoed.
#' @param value Should the column names or positions be returned?
#' @param ignore.case Should case be ignored in regular expression matching?
#' @note This is mostly for interactive use
#' @author Sven Halvorson
#' @examples
#' find_cols(mtcars, ar, pg)
#' find_cols(mtcars, '^a')
#' find_cols(mtcars, 'ar', value = FALSE)
#' @export

find_cols = function(df, ..., value = TRUE, ignore.case = TRUE){

  if(!is.data.frame(df)){
    stop('df must be a data.frame')
  }

  # Capture the input, fix if supplied quoted strings
  arguments = dplyr::enquos(...) %>%
    purrr::map_chr(dplyr::quo_name)

  # if the user supplied a character vector, clean it up:
  if(length(arguments) == 1){
    if(stringr::str_detect(string = arguments, pattern = 'c\\(')){
      arguments = arguments %>%
        stringr::str_remove_all('c\\(|\\)|\"') %>%
        stringr::str_split(pattern = ', ', simplify = TRUE) %>%
        .[1,]}
  }
  arguments %>%
    purrr::map(.f = grep,
            x = colnames(df),
            ignore.case = ignore.case,
            value = value) %>%
    unlist %>%
    unique %>%
    sort


}






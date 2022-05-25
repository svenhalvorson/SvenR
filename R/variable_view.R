#' SPSS Style Variable Viewer
#' @param df a data frame
#' @description Create a table of column names and attributes.
#' @return a summary table of \code{df}
#' @export
#' @author Sven Halvorson (svenpubmail@gmail.com)
#' @examples
#' example_df = tibble::tibble(
#'   Goddess = c(1, 2, 3),
#'   Civilization = c(
#'     'Babylonian',
#'     'Sumerian',
#'     'Sumerian'
#'   ),
#'   Importance = runif(3),
#'   Date = lubridate::mdy(
#'     c(
#'       '01-30-1988',
#'       '05-22-2006',
#'       '11-02-2017'
#'     )
#'   )
#' )
#'
#' expss::val_lab(example_df[['Goddess']]) = c(
#'   'Tiamat' = 1,
#'   'Inanna' = 2,
#'   'Ninhursag' = 3
#' )
#'
#' expss::var_lab(example_df[['Date']]) = 'A random date'
#'
#' example_df %>%
#'   variable_view() %>%
#'   View()

variable_view = function(df){


  tibble::tibble(
    Name = colnames(df),
    Type = purrr::map_chr(df, typeof),
    Class = purrr::map_chr(
      df,
      function(x){
        paste0(class(x), collapse = ', ')
      }
    ),
    Label = purrr::map_chr(
      df,
      function(x){
        ifelse(
          'label' %in% names(attributes(x)),
          attr(x, 'label'),
          NA_character_
        )
      }
    ),
    Values = purrr::map_chr(
      df,
      function(x){
        if(!'labels' %in% names(attributes(x))){
          NA_character_
        }else{

          labels = attr(x, 'labels')
          paste0(
            paste0(
              labels,
              ' = ',
              names(labels)
            ),
            collapse = ' | '
          )

        }
      }
    )
  )
}


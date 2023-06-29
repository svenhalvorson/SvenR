#' Format Checkbox Columns
#' @description Modify a data frame representing a 'select all that apply'
#' style survey question. Makes implicit negative responses explicit while
#' keeping non-responses as is.
#' @param df A data frame
#' @param relabel Should the value label be set as the variable label?
#' @details The steps taken are:
#' \enumerate{
#'   \item Set the variable label as the (presumably singular) value label if \code{relabel = TRUE}
#'   \item Find the observations that are missing across all columns
#'   \item Remove value labels, replace missing values with zeroes
#'   \item Replace values with NA for completely missing observations
#' }
#' @return A data frame
#' @export
#' @author Sven Halvorson (svenpubmail@gmail.com)
#' @examples
# Make an example data set:
#' set.seed(0)
#' checkbox_example = tibble(
#'   TREATMENT = rep(c('treat', 'control'), each = 20),
#'   Q1 = sample(c(1, NA), size = 40, replace = TRUE),
#'   Q2 = sample(c(1, NA), size = 40, replace = TRUE),
#'   Q3 = sample(c(1, NA), size = 40, replace = TRUE)
#' )
#' # Note first & third rows are all missing
#'
#' # Set some value labels:
#' for(i in 1:3){
#'   lab = 1
#'   names(lab) = LETTERS[i]
#'   expss::val_lab(checkbox_example[paste0('Q',i)]) = lab
#' }
#'
#' # Make a new dataframe of just the formatted checkbox questions:
#' formatted_checkbox = checkbox_example %>%
#'   select(all_of(paste0('Q', 1:3))) %>%
#'   format_checkbox()
#'
#' attributes(formatted_checkbox[['Q1']])
#'
#' # Also can do assignment for a chunk of the data frame but it's a little trickier
#' checkbox_example[,paste0('Q', 1:3)] = format_checkbox(checkbox_example[,paste0('Q', 1:3)])
#' checkbox_example

format_checkbox = function(
  df,
  relabel = TRUE
){

  # goal is to:
  # 1. Set the column label as the value label from columns
  # 2. Find the observations that are missing across all columns
  # 3. Turn each column into a label-less binary
  # 4. Replace values with NA for completely absent observations (#2)


  # Store column labels if they exist:
  lab_fun = ifelse(
    test = relabel,
    yes = function(x){
      if('labels' %in% names(attributes(x))){
        names(attr(x, 'labels'))[1]
      } else{
        ''
      }
    },
    no = function(x){
      if('label' %in% names(attributes(x))){
        attr(x, 'label')
      } else{
        ''
      }
    }
  )

  col_labs = map_chr(
    .x = df,
    .f = lab_fun
  )

  # Find completely missing obs:
  all_mia = apply(
      X = df,
      MARGIN = 1,
      FUN = function(x){all(is.na(x))}
    )

  # Turn to label-less binary and replace:
  df = df %>%
    dplyr::mutate(
      dplyr::across(
        .cols = tidyr::everything(),
        .fns = haven::zap_label
      ),
      dplyr::across(
        .cols = tidyr::everything(),
        .fns = tidyr::replace_na,
        replace = 0
      ),
      dplyr::across(
        .cols = tidyr::everything(),
        .fns = replace,
        list = all_mia,
        values = NA_real_
      )
    )

  if(
    any(
      col_labs != ''
    )
  ){
    for(i in seq_along(col_labs)){
      attr(df[[i]], 'label') = col_labs[i]
    }
  }

  df

}


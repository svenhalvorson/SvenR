#' Coalesce Multiple Columns
#'
#' @param df a data frame
#' @param pattern pattern to split column names along using \code{stringr::str_split_fixed}
#' @param noisy Do you want messages about the values being coalesced?
#' @description Coalesce columns matching the LHS when splitting by \code{pattern}. Columns
#' are coalesced from left to right as they appear in \code{df}
#' @note Columns that do not contain \code{pattern} but match another column after splitting
#' will STILL be coalesced. In the example, the columns \code{c(value, value.x, value.y)} are
#' coalesced when \code{(pattern = stringr::fixed('.')}.
#' @return a data frame with coalesced columns
#' @export
#'
#' @examples
#' set.seed(1)
#' make_data = function(values){
#'   tibble::tibble(
#'     id = 1:10,
#'     value = sample(c(values, NA), size = 10, replace = TRUE),
#'     value2 = sample(c(toupper(values), NA), size = 10, replace = TRUE)
#'   )
#' }
#'
#' # Notice the last record has missing values for both value.x and value.y
#' sample_data = list(
#'   make_data(letters[1]),
#'   make_data(letters[2]),
#'   dplyr::select(make_data(letters[3]), -value2)
#' ) |>
#'   purrr::reduce(dplyr::full_join, by = 'id')
#'
#' coalesce_multi(sample_data)

coalesce_multi = function(
    df,
    pattern = stringr::fixed('.'),
    noisy = TRUE
){

  # first figure out what columns should be coalesced:
  colname_df = stringr::str_split_fixed(
    string = colnames(df),
    pattern = pattern,
    n = 2
  )
  colnames(colname_df) = c('prefix', 'suffix')

  colname_df = colname_df |>
    tibble::as_tibble() |>
    dplyr::mutate(
      colname = colnames(df)
    ) |>
    dplyr::group_by(prefix) |>
    dplyr::filter(dplyr::n() > 1) |>
    dplyr::ungroup()

  if(nrow(colname_df) == 0){
    warning('No columns coalesced by coalesce_multi')
    return(df)
  } else{

    for(column_prefix in unique(colname_df[['prefix']])){
      #browser()
      sub_df = dplyr::filter(colname_df, prefix == column_prefix)

      if(noisy){
        cat(
          paste0(
            'Coalescing c(',
            paste(sub_df[['colname']], collapse = ', '),
            ') into ',
            column_prefix,
            '\n\n'
          )
        )
      }

      new_col = df |>
        dplyr::select(
          tidyselect::all_of(sub_df[['colname']])
        ) |>
        as.list()

      df = dplyr::select(df, -tidyselect::all_of(sub_df[['colname']]))
      df[[column_prefix]] = dplyr::coalesce(!!!new_col)

    }

  }

  df

}

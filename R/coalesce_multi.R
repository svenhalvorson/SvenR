#' Coalesce Multiple Columns
#'
#' @param df a data frame
#' @param pattern pattern to split column names along using \code{stringr::str_split_fixed}
#' @param noisy Do you want messages about the columns being coalesced?
#' @description Coalesce columns matching the LHS when splitting by \code{pattern}. Columns
#' are coalesced from left to right as they appear in \code{df}
#' @note Columns that do not contain \code{pattern} but match another column after splitting
#' will STILL be coalesced. In the example, the columns \code{c(value, value.x, value.y)} are
#' coalesced when \code{(pattern = stringr::fixed('.')}.
#' @return a data frame with coalesced columns
#' @export
#'
#' @examples
#' # Let's say you have two two data sets about birds
#' # and you want to combine them to make a more complete version
#' # while prioritizing the woods data over the feeder data
#' woods = tibble::tibble(
#'   bird = c('Northern Flicker', 'Chesnut-backed Chickadee', 'California Quail'),
#'   group_size = c(NA, NA, 2L),
#'   food = c('bugs', NA, 'seeds')
#' )
#'
#' feeder = tibble::tibble(
#'   bird = c('Northern Flicker','Chesnut-backed Chickadee', 'Evening Grosbeak'),
#'   group_size = c(1L, 8L, 13L),
#'   food = c('seeds', NA, NA)
#' )
#'
#' # See what they look like when joined on "bird"
#' dplyr::full_join(
#'   x = woods,
#'   y = feeder,
#'   by = 'bird'
#' )
#'
#' # When we coalesce multi, it first looks for non-missing values
#' # from the woods (.x) and then from the feeder (.y):
#' dplyr::full_join(
#'   x = woods,
#'   y = feeder,
#'   by = 'bird'
#' ) |>
#'   coalesce_multi()
#'
#' # Note that it can coalesce values with
#' # different separators and even no suffix:
#' dplyr::full_join(
#'   x = woods,
#'   y = feeder,
#'   by = 'bird',
#'   suffix = c('', '~feeder')
#' ) |>
#'   coalesce_multi(pattern = '~')

coalesce_multi = function(
    df,
    pattern = stringr::fixed('.'),
    noisy = TRUE
){

  stopifnot(
    "`df` must be a data.frame" = checkmate::test_data_frame(df),
    "pattern must be a character" = checkmate::test_character(pattern)
  )

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

      sub_df = dplyr::filter(colname_df, prefix == column_prefix)

      if(noisy){
        message(
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

      drop_cols = setdiff(sub_df[['colname']], column_prefix)

      df[[column_prefix]] = dplyr::coalesce(!!!new_col)
      df = dplyr::select(df, -tidyselect::all_of(drop_cols))

    }

  }

  df

}

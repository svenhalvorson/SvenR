#' One-to-one left join
#' @description Just a simple wrapper around \code{dplyr::left_join} to stop myself
#' from accidentally many-to-one joining when I don't expect to.
#' @param x,y tbls to join
#' @param ... other arguments to be passed to \code{left_join}
#' @return a tbl
#' @export
#' @author Sven Halvorson
#' @note Saftey first!
#' @examples
#' \dontrun{
#' df1 = tibble(
#'   x = 1:5,
#'   y = letters[1:5],
#'   z = LETTERS[1:5]
#' )
#'
#' df2 = tibble(
#'   x = c(1:4, 4),
#'   j = LETTERS[5:1]
#' )
#'
#' safe_join(df1, df2)
#' safe_join(df1, df2, by = c('z' = 'j'), suffix = c('_left', '_right'))
#' }

safe_join = function(x, y, ...){

  new_df = x %>%
    dplyr::left_join(y, ...)

  if(nrow(x) < nrow(new_df)){
    stop('Unsafe joining!')
  }

  new_df

}


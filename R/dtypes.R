#' Data types
#' @param df A \code{data.frame}
#' @return A tibble of the types and classes of the columns of \code{df}
#' @export
#' @author Sven Halvorson
#' @examples
#' dtypes(iris)
#' @note I wanted a version of the pandas function so here it is
#'
dtypes = function(
  df
){

  stopifnot(is.data.frame(df))

  tibble::tibble(
    column = colnames(df),
    type = vapply(
      X = df,
      FUN = typeof,
      FUN.VALUE = character(1)
    ),
    class = lapply(
      X = df,
      FUN = class
    ) %>%
      lapply(paste, collapse = ', ') %>%
      unlist()
  )

}

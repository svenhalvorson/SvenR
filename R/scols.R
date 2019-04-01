#' Sort Columns
#' @description Useful for finding colum names
#' @note For interactive use
#' @author Sven Halvorson
#' @examples
#' scols(mtcars)
#' @export

scols = function(df){
  #' @param df a data frame
  sort(colnames(df))
}

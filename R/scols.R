#' Sort Columns
#' @description Useful for finding colum names
#' @param df a data frame
#' @note For interactive use
#' @author Sven Halvorson
#' @examples
#' scols(mtcars)
#' @export

scols = function(df){
  sort(colnames(df))
}

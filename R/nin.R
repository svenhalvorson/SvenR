# Not In
#' @description clearer, for me at least, version of !x %in% y
#' @author Sven Halvorson
#' @examples 'a' %nin% letters
#' 'a' %nin% LETTERS
#' @param x values to be matched
#' @param y values to be matched against
#' @seealso match
`%nin%` = function(x,y){
!(x %in% y)
}
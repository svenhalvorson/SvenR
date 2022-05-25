#' @title Not In
#' @description Inverse of infix \code{\%in\%}
#' @author Somebody else, not sure who
#' @examples 'a' %nin% letters
#' 'a' %nin% LETTERS
#' @param x values to be matched
#' @param y values to be matched against
#' @seealso match
#' @rdname nin
#' @export
"%nin%" = function(x,y){
!(x %in% y)
}

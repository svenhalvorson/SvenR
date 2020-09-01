#' @title Reverse In
#' @description Reverse of infix \code{\%in\%}
#' @author Sven Halvorse
#' @examples 'a' %nin% letters
#' 'a' %nin% LETTERS
#' @param x values to be matched against
#' @param y values to be matched
#' @seealso match
#' @rdname nin
#' @export
"%nin%" = function(x,y){
!(y %in% x)
}

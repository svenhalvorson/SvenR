#' @title Reverse In
#' @description Reverse of infix \code{\%in\%}
#' @author Sven Halvorse
#' @examples 'a' %rin% letters
#' LETTERS %rin% 'a'
#' @param x values to be matched against
#' @param y values to be matched
#' @seealso match
#' @rdname rin
#' @export
"%rin%" = function(x,y){
(y %in% x)
}

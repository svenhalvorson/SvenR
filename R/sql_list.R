#' SQL List
#' @description Format an atomic vector for use with a SQL 'IN' statements
#' @param x Atomic character or numeric vector
#' @author Sven Halvorson
#' @examples
#' paste(
#'   'SELECT nonsense',
#'   'FROM your_table',
#'   'WERE nonsense IN',
#'   sql_list(letters[1:5]),
#'   ';'
#' )
#' @export
#'
sql_list = function(x, quote = TRUE){

  if(
    any(
      !is.atomic(x),
      !(is.character(x) | is.numeric(x))
    )
  ){
    stop('x must be an atomic character or numeric vector')
  }

  if(quote){
    paste0(
      "('",
      paste0(
        x,
        collapse = "', '"
      ),
      "')"
    )

  }
  else{
    paste0(
      "(",
      paste0(
        x,
        collapse = ", "
      ),
      ")"
    )
  }

}

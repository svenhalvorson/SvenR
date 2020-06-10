#' SQL List
#' @description Format an atomic vector for use with a SQL 'IN' statements
#' @param x Atomic character or numeric vector
#' @param quote Should each entry be surrounded with single quotes?
#' @param wildcard Should each entry be surrounded with percent signs? Used for wildcard matching
#' @author Sven Halvorson
#' @examples
#' paste(
#'   'SELECT nonsense',
#'   'FROM your_table',
#'   'WERE nonsense LIKE ANY',
#'   sql_list(letters[1:5], wildcard = TRUE),
#'   ';'
#' )
#' @export
#'
sql_list = function(
  x,
  quote = TRUE,
  wildcard = FALSE
){

  if(
    any(
      !is.atomic(x),
      !(is.character(x) | is.numeric(x))
    )
  ){
    stop('x must be an atomic character or numeric vector')
  }

  if(!quote & wildcard){
    stop('quote must be TRUE to use wildcard')
  }

  if(wildcard){
    paste0(
      "('%",
      paste0(
        x,
        collapse = "%', '%"
      ),
      "%')"
    )

  }
  else if(quote){
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

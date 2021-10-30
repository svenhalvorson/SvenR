#' Dictionary Style Renaming
#'
#' @param df A data frame
#' @param old_names Character vector of names in \code{df}
#' @param new_names Character vector of new names of the same length as \code{old_names}
#' @param match_all Do all of \code{old_names} need to be in the columns of \code{df}?
#' @note I like option in pandas to rename using a dictionary so here is an R version.
#' @return \code{df} with new names
#' @export
#'
#' @examples
#' df = tibble(
#'   Hammurabi = 1:3,
#'   Cyrus = letters[1:3],
#'   David = LETTERS[1:3]
#' )
#'
#' rename_from = c(
#'   'Cyrus',
#'   'Hammurabi',
#'   'Alexander'
#' )
#'
#' rename_to = c(
#'   'Cambyses',
#'   'Nebuchadnezzar',
#'   'Ptolemy'
#' )
#'
#' rename_dict(
#'   df,
#'   old_names = rename_from,
#'   new_names = rename_to,
#'   match_all = FALSE
#' )

rename_dict = function(
  df,
  old_names,
  new_names,
  match_all = TRUE
){

  if(
    any(
      !is.data.frame(df),
      !is.character(old_names),
      !is.character(new_names),
      length(old_names) != length(new_names)
    )
  ){
    stop('Unacceptable arguments supplied') # This is vague but for now, whatever
  }

  # Might be important sometimes that we assert that everything in the
  # dictionary matches a column name in df
  if(match_all){
    if(
      !all(old_names %in% colnames(df))
    ){
      stop('Some values in old_names not found in columns of df')
    }
  }

  matches = match(
    x = old_names,
    table = colnames(df)
  )

  for(i in seq_along(matches)){

    if(!is.na(matches[i])){
      colnames(df)[matches[i]] = new_names[i]
    }

  }

  df
}



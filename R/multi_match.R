#' Multiple pattern matching
#' @description Match a character vector on multiple patterns.
#' @param strings A vector of strings to be matched
#' @param patterns A vector of patterns to match
#' @param replacements Replacement label vector of the same length as \code{patterns}. If missing, \code{patterns} is used.
#' @param ignore_case Should case be ignored in regular expression matching?
#' @param compress If \code{TRUE}, returns the first matched pattern (or label). Otherwise, returns a \code{tibble} of matches for each pattern
#' @param first If \code{TRUE}, then the first match is returned otherwise the last is returned. This is ignored if \code{compress = FALSE}.
#' @return If \code{compress = TRUE}, returns a character vector. Otherwise, returns a tibble.
#' @author Sven Halvorson
#' @examples
#' strings = c('abcde', 'bc', 'def', 'gjab', 'xyz')
#' patterns = c('ab', 'de', 'bc')
#' replacements = toupper(patterns)
#'
#' # Find the first match of each pattern:
#' multi_match(
#'   strings = strings,
#'   patterns = patterns,
#'   replacements = replacements
#' )
#'
#' # Make flags for matching each pattern:
#' multi_match(
#'   strings = strings,
#'   patterns = patterns,
#'   compress = FALSE
#' )
#'
#' @export

multi_match = function(
  strings,
  patterns,
  replacements,
  ignore_case = TRUE,
  compress = TRUE,
  first = TRUE
){

  # Write some checks here when we're satisfied

  # Check the labels
  if(missing(replacements)){
    replacements = patterns
  }
  else{
    if(
      !all(
        length(replacements) == length(patterns),
        is.character(replacements),
        is.atomic(replacements)
      )
    ){
      stop('replacements must be missing or a character vector of the same length as patterns')
    }
  }

  # We're going to use grepl on each pattern regardless of whether compress is TRUE
  # so we'll start there:
  match_mat = lapply(
    patterns,
    grepl,
    x = strings,
    ignore.case = ignore_case
  )

  match_mat = suppressMessages(
    tibble::as_tibble(
      match_mat,
      .name_repair = 'universal'
    ) %>%
    # I usually use binaries:
    dplyr::mutate_all(
      ifelse,
      yes = 1,
      no = 0
    )
  )

  colnames(match_mat) = replacements

  # If we don't want to compress
  if(!compress){
    return(match_mat)
  }

  # Otherwise we need to do some kind of coalesce thing:
  match_mat = match_mat %>%
    mutate_all(
      function(y){
        replace(
          x = y,
          list = y == 0,
          values = NA
        )
      }
    )

  # Want to use an index here as there could be repeated replacements
  for(i in seq_along(replacements)){
    match_mat[[replacements[i]]] = replace(
      x = match_mat[[replacements[i]]],
      list = match_mat[[replacements[i]]] == 1,
      values = replacements[i]
    )
  }

  # Now reverse if necessary and coalesce:
  if(!first){
    match_mat = rev(match_mat)
  }
  coalesce(!!!match_mat)

}


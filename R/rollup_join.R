#' Rollup join
#' @description Join a list of data sets and check for preserving unique ids.
#' The idea for this function is that I frequently assemble many data frames
#' and wish to combine them at the end of the script for export. This helps
#' make sure you preserve the uniqueness of the ids and tells you where the
#' problem is ocurring.
#' @param dfs A named list of \code{data.frames}
#' @param ... The keys to join on
#' @param how The merging style. One of \code{c('left', 'right', 'inner', 'full')}
#' @author Sven Halvorson
#' @examples
#'
#' d1 = tibble(id = 1:10,
#'             a = sample(letters, 10, replace = TRUE))
#' d2 = tibble(id = 1:5,
#'             b = sample(letters, 5, replace = TRUE))
#' d3 = tibble(id = c(1:3, 1),
#'             c = sample(letters, 4, replace = TRUE))
#' rollup_join(mget(paste0('d', 1:2)), id)
#' rollup_join(mget(paste0('d', 1:3)), id)
#' @note It's easy to get a named list if you use mget
#' @export


# now the function to get the whole thing together
rollup_join = function(dfs, ..., how = 'left'){

  # get some stuff here to help with the tidy eval
  keys = dplyr::enquos(...)
  keys_chr = purrr::map_chr(.x = keys,
                            .f = dplyr::quo_name)
  right_names = names(dfs)[-1]

  # Saftey first:
  if(!all(is.list(dfs),
         length(dfs) > 1,
         all(lapply(dfs), is.data.frame),
         length(names(dfs)) == nrow(dfs))){
    stop('dfs must be a named list of data frames')
  }
  if(!all(length(how) == 1,
          how %in% c('left', 'right', 'inner', 'full'))){
    stop("how must be in c('left', 'right', 'inner', 'full')")
  }


  # Helper to check uniqueness:
  check_distinct = function(df){
    nrow(dplyr::distinct(df, !!!keys)) == nrow(df)
  }

  # helper to join
  merge_distinct = function(left, right, how, right_name){

    # choose the merge style and execute
    merge_dir = switch(how,
                       'left' = left_join,
                       'right' = right_join,
                       'inner' = inner_join,
                       'full' = full_join)
    temp = merge_dir(left, right, by = keys_chr)

    if(!check_distinct(temp)){
      #browser()
      stop(paste(paste(keys_chr, collapse = ', '),
                 'is not unique after merging with',
                 last(right_name)))
    }
    temp
  }



  purrr::reduce(.x = dfs,
               .f = merge_distinct,
               how = how,
               right_name = right_names)
}



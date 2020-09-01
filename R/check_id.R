#' Check IDs
#' @description Test keys for uniqueness or try to find unique keys
#' @param df A data frame
#' @param ... Columns within df. These can be quoted or NSE
#' @param max_depth The maximum number of columns to look for a unique key among.
#' @details The intent of this function is twofold. First, it will test if a set
#' of supplied columns are a unique key. By 'unique key' we mean that each
#' combination of those variables uniquely specifies a row in df.
#' Supply columns to \code{...} for this functionality. \cr \cr
#' The second purpose of check_id is to determine which sets of column(s)
#' if any, determine a unique key for \code{df}. If any do, they will be listed.
#' Othewise, the closest key(s) will be listed. The output in this case
#' is a data frame of statistics on the attempts.
#' @author Sven Halvorson
#' @examples
#' check_id(mtcars)
#' check_id(mtcars, cyl, mpg)
#' check_id(mtcars, c('cyl', 'mpg'))
#' @export
#' @import tidyverse


check_id = function(df, ..., max_depth = 3){


  # Preliminaries -----------------------------------------------------------

  # Capture df's name & row count
  df_name = dplyr::enquo(df) %>%
    (dplyr::quo_name)
  nrow_df = nrow(df)

  # Check specific combination ----------------------------------------------
  # Scenario 1 is where we want to check if a combination of columns is unique
  arguments = dplyr::enquos(...) %>%
    purrr::map_chr(dplyr::quo_name)
  # if the user supplied a character vector, clean it up:
  if(length(arguments) == 1){
    if(stringr::str_detect(string = arguments, pattern = 'c\\(')){
      arguments = arguments %>%
        stringr::str_remove_all('c\\(|\\)|\"') %>%
        stringr::str_split(pattern = ', ', simplify = TRUE) %>%
        .[1,]}
  }

  if(length(arguments) > 0){

    dupe = dupes(df[arguments])

    # if all unique, state that
    if(sum(dupe) == 0){
      cat('\nKey: ', paste(arguments, collapse = ' * '), ' \n\tis unique within ', df_name, sep = '')
    }
    else{
      # if not unique, give summary
      sum_nonunique = sum(dupe)
      percent_unique = (nrow_df - sum_nonunique)/nrow_df
      cat('\nKey: ', paste(arguments, collapse = ' * '), ' \n\tNot unique within ', df_name, '\n\t',
          round_per(percent_unique),'% of rows are unique \n\t',
          format(sum_nonunique, big.mark = ','), ' non-unique rows', sep = '')
    }
    return(invisible(df))
  }

  # Find unique combination -------------------------------------------------

  # Scenario 2 is where we only supply the max depth and are looking for
  # any combinations of variables that are unique within the data frame
  # I think we'll return a matrix of stats about the column combionations

  # use this function to make combination list:
  col_combos = function(n){
    combo = colnames(df) %>%
      combn(m = n) %>%
      tibble::as_tibble(.name_repair = 'minimal') %>%
      as.list()
  }

  # Now we want to try every combination. I think it is probably a good
  # idea to complete whatever iteration on max_depth we're at but we
  # don't need to go deeper.

  # maybe make a data frame to store the output:
  output = matrix(NA_character_, nrow = 0, ncol = max_depth + 3) %>%
    tibble::as_tibble(.name_repair = 'minimal')



  # store whether we've found a unique combo and start looping
  unique_found = 0
  for(i in 1:min(max_depth, ncol(df))){

    combos = col_combos(i)

    # try every combination
    for(combo in combos){
      dupe = dupes(df[combo])
      sum_nonunique = sum(dupe)


      if(sum_nonunique == 0){
        if(unique_found == 0){
          cat('Unique key(s) within ', df_name, ':\n', sep = '')
        }
        cat('\t', paste(combo, collapse = ' * '), '\n', sep = '')
        unique_found = 1
      }

      # add to data frame
      new_row = c(combo,
                  rep(NA, times = max_depth - i),
                  as.numeric(sum_nonunique == 0),
                  round_per((nrow_df - sum_nonunique)/nrow_df),
                  sum_nonunique) %>%
        matrix(nrow = 1)
      output = rbind(output, new_row, stringsAsFactors = FALSE)

    }
    if(unique_found == 1){
      break()
    }

  }

  # Format output
  colnames(output) = c(paste0('var', 1:max_depth), 'unique', 'per_unique', 'n_nonunique')
  # if we don't find a unique combo, give the nearest one:
  if(unique_found == 0){
    closest_unique = output %>%
      dplyr::filter(n_nonunique == min(n_nonunique))
    pats = closest_unique[1:max_depth] %>%
      apply(MARGIN = 1, FUN = paste, collapse = ' * ') %>%
      stringr::str_remove_all(pattern = ' \\* NA')
    pats = paste(pats, collapse = '\n\t\t\t' )
    # kind of going to a lot of effort for the case where there are multiple
    # equally 'unique' patterns...
    cat('\nNo unique keys found.\nClosest key(s):\t\t\t', pats, '\n\n',
        'With any of these keys...\n',
        'Total rows:\t\t', nrow_df, '\n',
        '# non-unique rows:\t', closest_unique[['n_nonunique']][1], '\n',
        'Percent unique rows:\t', closest_unique[['per_unique']][1], "%", sep = '')


  }


}

#' Count IDs
#' @description Computes \code{n_distinct} on specified columns and gives row count.
#' @note Defaults to op_sys, visit_sys, and patient_sys if \code{...} is not supplied. Ungroups data frames with a warning.
#' @param df A data frame
#' @param ... Unquoted column names in \code{df}
#' @return \code{df}, intended for side effect use.
#' @author Sven Halvorson
#' @examples
#' df = tibble(op_sys = 1:5,
#'             visit_sys = c(1, 1, 2, 3, 4),
#'             patient_sys = c(1, 1, 2, 2, 3))
#' count_ids(df)
#' count_ids(df, op_sys)
#' @export

count_ids = function(df, ...){

  ids = quos(...)

  # if you don't supply ids, do the phds normal three
  if(length(ids) == 0){
    ids = quos(patient_sys, visit_sys, op_sys)
  }

  print(paste(nrow(df), "observations"))

  if(is.grouped_df(df)){
    warning('df is grouped, ungrouping...')
    df = df %>%
      ungroup
  }

  # unique ids
  id_counts = df %>%
    summarize_at(.vars = vars(!!!ids), .funs = n_distinct) %>%
    print

  # return to
  invisible(df)

}


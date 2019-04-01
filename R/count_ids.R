#' Count IDs
#' @description Computes \code{n_distinct} on specified columns and gives row count.
#' @note Defaults to op_sys, visit_sys, and patient_sys if \code{...} is not supplied.
#' @return \code{df}, intended for side effect use.
#' @author Sven Halvorson

count_ids = function(df, ...){

  #' @param df A data frame
  #' @param ... Unquoted column names in \code{df}

  library("dplyr")
  ids = quos(...)

  # if you don't supply ids, do the phds normal three
  if(length(ids) == 0){
    ids = quos(patient_sys, visit_sys, op_sys)
  }

  print(paste(nrow(df), "observations"))

  # unique ids
  id_counts = df %>%
    summarize_at(.vars = vars(!!!ids), .funs = n_distinct) %>%
    print

  # return to
  invisible(df)

}


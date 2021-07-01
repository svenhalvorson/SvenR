#' Combine cases
#' @description Groups \code{.data} by \code{...} and applies \code{.f} to all other columns
#' @param .data A data frame
#' @param ... Unquoted grouping variables within \code{.data}
#' @param .f A summary function. Defaults to first non-missing value
#' @return a tbl
#' @export
#' @author Sven Halvorson
#' @examples
#' \dontrun{
#' example_data = tibble(
#'   id = sample(letters, size = 100, replace = TRUE),
#'   bin = sample(0:1, size = 100, replace = TRUE),
#'   normal = rnorm(n = 100)
#' ) %>%
#'   arrange(id, bin, normal)
#'
#' example_data[2:ncol(example_data)] = lapply(
#'   example_data[2:ncol(example_data)],
#'   function(x){x[rnorm(length(x)) < -0.5] = NA;x}
#' )
#' combine_cases(
#'   .data = example_data,
#'   id
#' )
#' }


# Let's write a function to combine cases vertically. I'm thinking of spots
# where we have duplicates and want to have a way to resolve them.
combine_cases = function(
  .data,
  ...,
  .f
){


  # If no function is supplied, then pick the first non-missing
  # value
  if(missing(.f)){

    .f = function(x){

      non_miss = x[!is.na(x)]

      if(length(non_miss) > 0){
        non_miss[1]
      }
      else{
        NA
      }
    }

  }

  .data %>%
    group_by(...) %>%
    summarize(
      across(
        everything(),
        .f
      )
    )
}

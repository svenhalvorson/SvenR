#' Labelled vectors to continuous
#' @description Convert a vector to the numeric version of its value labels
#' @param x an atomic numeric vector with the attribute "labels"
#' @details \code{labelled_to_continuous} first converts the values \code{x} to
#' their associated labels. Then it returns \code{as.numeric(x)}. The intended
#' use case of this is when a continuos measure was ingested as a categorical data type
#' and the labels contain the desired values (wrong recodes).
#' @return a numeric vector
#' @export
#' @author Sven Halvorson (svenpubmail@gmail.com)
#' @examples
#' labelled_vector = 1:4
#' expss::var_lab(labelled_vector) = 'How many times have you read Enuma Elish?'
#' expss::val_lab(labelled_vector) = c(
#'   'Prefer not to answer' = 1,
#'   '0' = 2,
#'   '1' = 3,
#'   '2' = 4
#' )
#' labelled_to_continuous(labelled_vector)
#'
labelled_to_continuous = function(x){

  if(
    any(
      !'labels' %in% names(attributes(x)),
      !is.numeric(x),
      !is.atomic(x)
    )
  ){
    stop('x must be a numeric vector with the "labels" attribute')
  }

  # Wish we had python dictionary replacement here so...
  value_cross = tibble::tibble(
    values = x %>%
      attr('labels') %>%
      unname(),
    labels = x %>%
      attr('labels') %>%
      names()
  )

  # Save this
  if('label' %in% names(attributes(x))){
    var_lab_save = attr(x, 'label')
  }

  result = tibble::tibble(
    values = expss::drop_all_labels(x)
  ) %>%
    dplyr::left_join(
      value_cross,
      by = 'values'
    ) %>%
    dplyr::pull(labels)

  if(exists('var_lab_save')){
    expss::var_lab(result) = var_lab_save
  }

  as.numeric(result)
}



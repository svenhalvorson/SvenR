#' Pad MRN
#' @param mrn Vector of MRNs
#' @return A character vector of MRNs each having 8 characters and with leading zeroes
#' @export
#' @note This shouldn't always be used as some local MRNs are not supposed to have 8 digits
#' @author Sven Halvorson
#' @examples pad_mrn(c(12345678, 7654321))
pad_mrn = function(mrn){
  
  stringr::str_pad(
    string = mrn,
    width = 8,
    side = 'left',
    pad = '0'
  )
  
}
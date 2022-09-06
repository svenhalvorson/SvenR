#' Get latest file
#'
#' @param path Path to a directory to search within
#' @param pattern Pattern of files to look for
#' @param full.names Should the complete paths be returned?
#' @param ... Other arguments for \code{list.files}
#' @details I have a habit of putting the YYYYMMDD date into the files that I save
#' in order to keep old versions. This function helps find the last version of a file
#' by extracting those 8 digit strings, finding a maximumn, and returning the file(s)
#' that have that max in their name. Note that this will totally crash and burn
#' if the dates are in another format or there are other 8+ digit sequences in the file names.
#' @return a character representation of a path
#' @export
#' @author Sven Halvorson (svenpubmail@gmail.com)
#' @examples
#' get_latest_file(
#'   path = '//psi-svr-filer.uoregon.edu/P50/radx_latinx_collection/data/external/site_info',
#'   pattern = 'cleaned_schedule'
#' )
#' @seealso \code{list.files}

get_latest_file = function(
  path,
  pattern = NULL,
  full.names = TRUE,
  ...
){

  # List the files in path
  file_list = list.files(
    path = path,
    pattern = pattern,
    full.names = full.names,
    ...
  )

  # Extrat YYYYMMDD
  file_dates = file_list %>%
    stringr::str_split(pattern = '/') %>%
    purrr::map_chr(.f = function(x){
      dplyr::last(unlist(x))
    }
    ) %>%
    stringr::str_extract(pattern = '[0-9]{8}') %>%
    as.numeric()

  # Find the max
  latest_date = max(file_dates, na.rm = TRUE)

  if(is.infinite(latest_date)){
    stop('No dates found among the names of files')
  }

  latest_file = file_list[file_dates == latest_date]

  if(length(latest_file) > 1){
    warning('Multiple files with the same date found')
  }

  latest_file
}

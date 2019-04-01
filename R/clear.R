#' Clear Workspace
#' @description Clears specified environment and console
#' @note This does not remove loaded package. Restart your R session before getting the final output.
#' @author Sven Halvorson
#' @examples clear()
#' @export

clear <- function(env = globalenv()){

  #' @param env An environment
  rm(list = ls(envir = env), envir = env)

  # This doesn't actually remove the old text, just makes it scroll down a bunch
  cat("\014")
  invisible(NULL)
}

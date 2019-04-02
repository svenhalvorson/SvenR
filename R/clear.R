#' Clear Workspace
#' @description Clears specified environment and console
#' @param env An environment
#' @note This does not remove loaded package. Restart your R session before getting the final output.
#' @author Sven Halvorson
#' @examples clear()
#' @export
clear <- function(env = globalenv()){


  rm(list = ls(envir = env), envir = env)

  # This doesn't actually remove the old text, just makes it scroll down a bunch
  cat("\014")
  invisible(NULL)
}

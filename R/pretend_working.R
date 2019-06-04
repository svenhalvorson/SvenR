#' Pretend to Work
#' @description Creates poorly veiled wizbangs that might make it look
#'like someting important is happening on your computer
#' @param minutes run time
#' @author Sven Halvorson
#' @examples pretend_working(2)
#' @export

pretend_working <- function(minutes = 5){

  start_time = Sys.time()

  # So we want some other functions here like a loading bar

  while(difftime(time1 = Sys.time(), time2 = start_time, units = "mins") < minutes){
    func <- sample(x = c("bar", "flashy", "wiki",
                         "stack", "headlines",
                         "message"), size = 1, prob = c(0.2, 0.2, 0.2, 0.1, 0.1, 0.2))

    switch(EXPR = func,
           bar = progress_bar(),
           flashy = flashy_bar(),
           wiki = rand_wiki(),
           stack = rand_stack(),
           message = buncha_messages(),
           headlines = headlines())

    cat("\n\n\n\n")

  }


}

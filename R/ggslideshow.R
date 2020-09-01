#' Slideshow of ggplots
#' @param plots a list of ggplot objects
#' @param delay the delay in seconds
#' @note This is mostly for interactive use. It just prints the plots in order#'
#' @export
#' @author Sven Halvorson
#' @examples
#' make_iris_plot = function(sp){
#'   iris %>%
#'     filter(Species == sp) %>%
#'     ggplot(aes(x = Sepal.Width, y = Sepal.Length)) +
#'     geom_point() +
#'     labs(title = sp)
#' }
#'
#' unique(iris$Species) %>%
#'   lapply(make_iris_plot) %>%
#'   ggslideshow()

ggslideshow = function(
  plots,
  delay = 3
){

  if(!is.list(plots)){
    stop('plots must be a list of ggplot objects')
  }

  plot_count = length(plots)

  plots = Filter(
    ggplot2::is.ggplot,
    x = plots
  )

  if(length(plots) < plot_count){
    print('non-ggplot objects removed from plots')
  }

  for(i in seq_along(plots)){
    print(plots[[i]])
    Sys.sleep(time = delay)

  }

  invisible(0)

}

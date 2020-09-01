#' Merge time intervals
#' @description Join adjacent or redundant time intervals across ids
#' @param df  A \code{dataframe}
#' @param start_time The unquoted name of the starting time column in \code{df}
#' @param end_time The unquoted name of the ending time column in \code{df}
#' @param ... Optional grouping columns, unquoted
#' @param tolerance A number specifying how far apart start and end times can be
#' to combine.
#' @param units The units for tolerance. One of \code{c('seconds', 'minutes', 'hours', 'days', 'years')}
#' @param simplify Should the results be simplified and joined?
#' @param plots Should plots be generated for each group?
#' @examples
#' data(periods_data)
#' merged_periods = merge_periods(
#'   periods_data,
#'   start_time = ts_start,
#'   end_time = ts_end,
#'   id,
#'   tolerance = 3,
#'   units = 'minutes',
#'   simplify = FALSE,
#'   plots = TRUE
#' )
#'
#' SvenR::ggslideshow(merged_periods$plot)
#' @author Sven Halvorson
#' @export merge_periods

merge_periods = function(
  df,
  start_time,
  end_time,
  ...,
  tolerance = 0,
  units = 'minutes',
  simplify = TRUE,
  plots = FALSE
){

  # TODO argument checks

  # Check that the units are one of the few we'll accept and assign the function
  # that will compute the appropriate difference given the tolerance
  if(
    any(
      length(units) != 1,
      !units %in% c('seconds', 'minutes', 'hours', 'days', 'years')
    )
  ){
    stop("units must be one of c('seconds', 'minutes', 'hours', 'days', 'years')")
  } else{
    units_fun = switch(
      units,
      seconds = lubridate::seconds,
      minutes = lubridate::minutes,
      hours = lubridate::hours,
      days = lubridate::days,
      years = lubridate::years,
    )
  }
  # Subtraction function:
  if(tolerance == 0){
    units_sub = identity
  } else{
    units_sub = function(x){
      x - units_fun(tolerance)
    }
  }

  # Capture input
  start_time = dplyr::enquo(start_time)
  start_time_s = dplyr::quo_name(start_time)
  end_time = dplyr::enquo(end_time)
  end_time_s = dplyr::quo_name(end_time)
  grouping_vars = dplyr::enquos(...)
  grouping_vars_s = grouping_vars %>%
    purrr::map_chr(dplyr::quo_name)


  # Check for missing times:
  nrow_df = nrow(df)
  df = df %>%
    dplyr::filter(
      !is.na(!!start_time),
      !is.na(!!end_time)
    )
  if(nrow(df) < nrow(df)){
    warning('Missing times detected and deleted')
  }

  # make sure data is sorted and nested properly
  cat('\n\nSorting data...\n\n')
  df = df %>%
    dplyr::arrange(!!start_time, !!end_time) %>%
    dplyr::nest_by(!!!grouping_vars)
  cat('\n\nMerging periods...\n\n')

  # Run the function through the nested data set
  df = df %>%
    mutate(
      result = list(merge_one(data, start_time_s, end_time_s, units_sub))
    )

  # If we're just returning the result, do it this way:
  if(simplify){
    #browser()
    df = df %>%
      dplyr::select(-data) %>%
      tidyr::unnest(cols = c(result)) %>%
      dplyr::select(!!!grouping_vars, !!start_time, !!end_time)
    return(df)
  }else{
    if(plots){
      cat('\n\nPlotting results...\n\n')


      df = df %>%
        dplyr::mutate(
          plot = list(
            plot_periods(
              data,
              result,
              start_time_s,
              end_time_s
            )
          )
        )
    }
    df

  }

}

# Now use this function to do the merging for a single set. I think
# I'll just inherit the other information from the execution environment
# of merge_periods
merge_one = function(
  df,
  start_time_s,
  end_time_s,
  units_sub
){
  #browser()
  # First is the simple case of one row:
  if(nrow(df) == 1){
    return(df)
  }

  # Initialize the stack
  stack = df %>%
    dplyr::slice(1)
  #browser()
  # Scroll through the rows of the stack:
  for(i in 2:nrow(df)){

    # First check is just whether the new endpoint is actually beyond the
    # current one. IF it's not, we do nothing.
    if(
      df[[end_time_s]][i] > dplyr::last(stack[[end_time_s]])
    ){

      # now if the next start time is within the tolerance of the previous start time
      # then we merge:
      if(
        units_sub(df[[start_time_s]][i]) <= dplyr::last(stack[[end_time_s]])
      ){

        stack[[end_time_s]][nrow(stack)] = df[[end_time_s]][i]

      }else{
        # Otherwise, we add this row to the stack
        stack = stack %>%
          bind_rows(
            slice(df, i)
          )
      }
    }
  }

  stack
}

plot_periods = function(
  orig_data,
  merged_data,
  start_time_s,
  end_time_s
){


  combined_df = orig_data %>%
    dplyr::mutate(
      mgroup = 'raw'
    ) %>%
    dplyr::bind_rows(merged_data) %>%
    dplyr::mutate(
      mgroup = tidyr::replace_na(mgroup, 'merged'),
      row = dplyr::row_number()
    )
  #browser()
  ggplot2::ggplot(
    data = combined_df,
    mapping = ggplot2::aes_string(
      x = start_time_s,
      xend = end_time_s,
      y = 'row',
      yend = 'row',
      color = 'mgroup'
    )
  ) +
    ggplot2::geom_segment(size = 2) +
    ggplot2::scale_y_discrete(
      labels = function(x){ifelse(x %% 5 == 1, x, '')}
    ) +
    ggplot2::theme_minimal() +
    ggplot2::scale_color_manual(
      values = c(
        'raw' = 'firebrick',
        'merged' = 'darkorchid4'
      )
    ) +
    ggplot2::theme(
      legend.position = 'bottom'
    ) +
    ggplot2::labs(
      x = ggplot2::element_blank(),
      y = ggplot2::element_blank(),
      color = ggplot2::element_blank()
    )



}

#' Time Weighted Averages
#' @description This function computes time weighted averages of \code{value_var} across zero or more groups.
#' Averages can be computed by trapezoids or left/right endpoints. Time weighted averages are
#' computed relative to a reference value. They can be computed above, below, or about the supplied
#' value reference value. By default, they are computed as above 0.

#' @details If multiple rows have the same grouping variables and time, the median value will be selected.
#' Rows with missing. If only one value within a grouping level is supplied, that value will be returned.d
#' \code{twa} also computes the total minutes elapsed, the largest and smallest gap between consecutive points,
#' and the number of values received, used, and omitted.
#' @param df a data frame, assumed to be in a 'long form' with time values in a single column
#' @param value_var the value to be avaraged, a column within df
#' @param time_var the time variable for weighting. A column within df of class \code{POSIXct}
#' @param ... grouping variables within df
#' @param method method to compute TWA, one of \code{c('trapezoid', 'left', 'right')}
#' @param ref a value to compute the TWA relative to
#' @param ref_dir the direction to compute the average relative to ref, one of \code{c('above', 'below', 'about')}
#' @return a data frame containing any grouping variables, the computed twa, and some other summary statistics
#' @examples
#' start_date = ymd_hms('2019-01-01 00:00:00')
#' time_dat = tibble(id = c(1, 1, 1, 1, 2, 2),
#'                   val = c(4, 6, 8, 6, 1, NA),
#'                   t = minutes(c(0, 10, 15, 45, 0, 10)) + start_date)
#' twa(df = time_dat, value_var = val, time_var = t, id)
#' @author Sven Halvorson
#' @export
twa = function(df, value_var, time_var, ...,
               method = 'trapezoid', ref = 0, ref_dir = 'above'){

  # capture the potential NSE
  value_var = enquo(value_var)
  value_var_s = quo_name(value_var)
  time_var = enquo(time_var)
  time_var_s = quo_name(time_var)
  group_vars = enquos(...)
  group_vars_s = group_vars %>%
    map_chr(quo_name)

  # Check whether we have the right datatypes
  # if(!is.data.frame(df)){
  #   stop('df must be a data frame')
  # }
  # if(!quo_name(time_var) %in% colnames())


  # clean time points -------------------------------------------------------
  # so we'll first start out by making sure that:

  # 1) We're sorted & grouped properly
  df = df %>%
    arrange(!!time_var)
  if(length(group_vars) != 0){
    df = df %>%
      group_by(!!!group_vars) %>%
      arrange(!!!group_vars)
  }

  # 2) If there are missing outputs or times, record and then delete them.
  original_readings = df %>%
    summarize(n_meas = n())

  miss_output = df %>%
    mutate(missing_either = pmax(is.na(!!time_var), is.na(!!value_var))) %>%
    summarize(n_na = sum(missing_either))
  df = df %>%
    filter(!is.na(!!value_var),
           !is.na(!!time_var))

  # 3) We have only one reading per time point*group
  df = df %>%
    group_by(!!time_var, add = TRUE) %>%
    summarize(!!value_var := median(!!value_var)) %>%
    ungroup

  # regroup if needed to count actual data used:
  if(length(group_vars) != 0){
    df = df %>%
      group_by(!!!group_vars) %>%
      arrange(!!!group_vars)
  }
  used_readings = df %>%
    summarize(n_used = n())


  # Compute TWA -------------------------------------------------------------

  # Now we'll go ahead and compute the TWA. We'll need to determine
  # which method of computing it we'll use and whether we're using
  # a reference value
  multiplier = ifelse(ref_dir == 'above', 1, -1)
  lead_lag = ifelse(method == 'right', lag, lead)
  # Now create the times and values:
  df = df %>%
    mutate(method = method,
           dir = ref_dir,
           time_shift = lead_lag(!!time_var),
           time_diff = difftime(!!time_var, time_shift, units = 'mins'),
           time_diff = abs(as.numeric(time_diff)),
           lead_val = lead(!!value_var),
           new_val = case_when(method == 'trapezoid' ~
                                 multiplier*(0.5*(lead_val + !!value_var) - ref),
                               dir == 'below' ~ ref - !!value_var,
                               dir == 'above' ~ !!value_var -ref,
                               dir == 'about' ~ abs(!!value_var - ref)),
           weighted_val = pmax(new_val*time_diff, 0)) %>%
    # now summarize the times and values. We'll use a maximum
    # in the case that there is only one reading
    summarize(total_min = sum(time_diff, na.rm = TRUE),
              total_weight = sum(weighted_val, na.rm = TRUE),
              max_measure = max(!!value_var),
              max_gap = max(time_diff, na.rm = TRUE),
              max_gap = replace(max_gap, is.infinite(max_gap), 0),
              min_gap = min(time_diff, na.rm = TRUE),
              min_gap = replace(min_gap, is.infinite(min_gap), 0)) %>%
    mutate(twa = total_weight/total_min,
           twa = case_when(total_min > 0 ~ twa,
                           TRUE ~ max_measure)) %>%
    # nifty trick to change the select based on whether group_vars were supplied
    when(length(group_vars) == 0 ~ select(., twa, total_min, max_gap, min_gap),
         ~ select(., !!!group_vars, twa, total_min, max_gap, min_gap))

  # attach other measures and export ----------------------------------------

  # if we have no grouping variables:
  bind_fun = ifelse(length(group_vars) == 0, bind_cols, function(x,y){suppressMessages(full_join(x,y))})

  # join summaries and return
  df  %>%
    bind_fun(original_readings) %>%
    bind_fun(used_readings) %>%
    bind_fun(miss_output)

}







#' Time Weighted Averages
#' @description This function computes time weighted averages of \code{value_var} across zero or more groups.
#' Averages can be computed by trapezoids or left/right endpoints. Time weighted averages can be computed
#' with raw values or relative to a reference. Calculations can be above below, or about the supplied
#' reference value. By default, they are computed as raw.

#' @details If multiple rows have the same grouping variables and time, the median value will be selected.
#' Rows with missing. If only one value within a grouping level is supplied, that value will be returned.d
#' \code{twa} also computes the total time elapsed, the largest and smallest gap between consecutive points,
#' and the number of values received, used, and omitted. When \code{time_var} is \code{POSIXct}, \code{twa}
#' will default to minutes.
#' @param df a data frame, assumed to be in a 'long form' with time values in a single column
#' @param value_var the value to be avaraged, a column within df
#' @param time_var the time variable for weighting. Either \code{POSIXct} or numeric.
#' @param ... grouping variables within df
#' @param method method to compute TWA, one of \code{c('trapezoid', 'left', 'right')}
#' @param ref a value to compute the TWA relative to
#' @param ref_dir the direction to compute the average relative to ref, one of \code{c('above', 'below', 'about')}
#' @return a data frame containing any grouping variables, the computed twa, and some other summary statistics
#' @examples
#' start_date = ymd_hms('2019-01-01 00:00:00')
#' time_dat = tibble(id = c(1, 1, 1, 1, 2, 2),
#'                   val = c(4, 6, 8, 6, 1, NA),
#'                   t = minutes(c(0, 10, 15, 45, 0, 10)) + start_date,
#'                   t2 = 1:6)
#' twa(df = time_dat, value_var = val, time_var = t, id)
#' twa(df = time_dat, value_var = val, time_var = t2, method = 'left', ref = 7, ref_dir = 'below')
#' @author Sven Halvorson
#' @export
twa = function(df, value_var, time_var, ...,
               method = 'trapezoid', ref = 0, ref_dir = 'raw'){

  # capture the potential NSE
  value_var = enquo(value_var)
  value_var_s = quo_name(value_var)
  time_var = enquo(time_var)
  time_var_s = quo_name(time_var)
  grouping_vars = enquos(...)
  grouping_vars_s = grouping_vars %>%
    map_chr(quo_name)

  # Check whether we have the right datatypes
  if(!is.data.frame(df)){
    stop('df must be a data frame')
  }
  if(any(!c(value_var_s, time_var_s, grouping_vars_s) %in% colnames(df))){
    stop('supplied columns not found in df')
  }
  if(!(is.numeric(df[[time_var_s]]) | is.POSIXct(df[[time_var_s]]))){
    stop('time_var must be numeric or POSIXct')
  }
  if(!is.numeric(df[[value_var_s]])){
    stop('value_var must be numeric')
  }
  if(length(ref) != 1 | !is.numeric(ref)){
    stop('ref incorrectly specified')
  }
  if(length(ref_dir) != 1 | !ref_dir %in% c('raw', 'above', 'below', 'about')){
    stop('ref_dir incorrectly specified')
  }
  if(ref_dir == 'raw' & ref != 0){
    stop('ref must be zero if ref_dir == "raw"')
  }



  # clean time points -------------------------------------------------------
  # so we'll first start out by making sure that:

  # 1) We're sorted & grouped properly
  df = df %>%
    arrange(!!time_var)
  if(length(grouping_vars) != 0){
    df = df %>%
      group_by(!!!grouping_vars) %>%
      arrange(!!!grouping_vars)
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
  if(length(grouping_vars) != 0){
    df = df %>%
      group_by(!!!grouping_vars) %>%
      arrange(!!!grouping_vars)
  }
  used_readings = df %>%
    summarize(n_used = n())


  # Compute TWA -------------------------------------------------------------

  # Now we'll go ahead and compute the TWA. We'll need to determine
  # which method of computing it we'll use and whether we're using
  # a reference value
  multiplier = ifelse(ref_dir == 'below', -1, 1)
  lead_lag = ifelse(method == 'right', lag, lead)
  difference_fun = ifelse(is.POSIXct(df[[time_var_s]]),
                          function(x, y){difftime(x, y, units = 'mins')},
                          function(x, y){x - y})

  # Now create the times and values:
  df = df %>%
    mutate(method = method,
           dir = ref_dir,
           time_shift = lead_lag(!!time_var),
           time_diff = difference_fun(!!time_var, time_shift),
           time_diff = abs(as.numeric(time_diff)),
           lead_val = lead(!!value_var),
           new_val = case_when(method == 'trapezoid' ~
                                 multiplier*(0.5*(lead_val + !!value_var) - ref),
                               dir == 'about' ~ abs(!!value_var - ref),
                               TRUE ~ multiplier*(!!value_var - ref)),
           weighted_val = new_val*time_diff,
           weighted_val = case_when(dir == 'raw' ~ weighted_val,
                                    TRUE ~ pmax(weighted_val, 0))) %>%
    # now summarize the times and values. We'll use a maximum
    # in the case that there is only one reading
    summarize(total_time = sum(time_diff, na.rm = TRUE),
              total_weight = sum(weighted_val, na.rm = TRUE),
              max_measure = max(!!value_var),
              max_gap = max(time_diff, na.rm = TRUE),
              max_gap = replace(max_gap, is.infinite(max_gap), 0),
              min_gap = min(time_diff, na.rm = TRUE),
              min_gap = replace(min_gap, is.infinite(min_gap), 0)) %>%
    mutate(twa = total_weight/total_time,
           twa = case_when(total_time > 0 ~ twa,
                           TRUE ~ max_measure)) %>%
    # nifty trick to change the select based on whether grouping_vars were supplied
    when(length(grouping_vars) == 0 ~ select(., twa, total_time, max_gap, min_gap),
         ~ select(., !!!grouping_vars, twa, total_time, max_gap, min_gap))

  # attach other measures and export ----------------------------------------

  # if we have no grouping variables:
  bind_fun = ifelse(length(grouping_vars) == 0, bind_cols, function(x,y){suppressMessages(full_join(x,y))})

  # join summaries and return
  df  %>%
    bind_fun(original_readings) %>%
    bind_fun(used_readings) %>%
    bind_fun(miss_output)

}







# Let's make some fake data to demonstrate the time interveal merging function
library('tidyverse')
library('lubridate')

set.seed(1)
# make some fake_ids and start_times
ids = 1:10
hours = sample(0:23, size = 10, replace = TRUE)
minutes = sample(0:60, size = 10, replace = TRUE)
start_times = paste0(
  '2020-11-03 ',
  hours, ':', minutes,':00'
) %>%
  ymd_hms()

periods_data = tibble(
  id = ids,
  start_times = start_times
)

make_ts = function(start_time){
  stop = 0
  size_param = sample(
    x = c(1, 2, 3),
    size = 1
  )

  # initialize_data frame:
  df = tibble(
    ts_start = start_time,
    ts_end = start_time + size_param*minutes(sample(1:10, 1))
  )
  #browser()
  while(stop == 0){
    size_param = (size_param*sample(x = c(0.5, 1, 2),size = 1)) %>%
      ceiling()

    df = df %>%
      bind_rows(
        tibble(
          ts_start = last(df$ts_end) + minutes(size_param*sample((-5):10, 1)),
          ts_end = ts_start + size_param*minutes(sample(1:10, 1))
        )
      )

    if(runif(1) > 0.97){
      stop = 1
    }

  }

  df

}

periods_data = periods_data %>%
  nest_by(id, start_times) %>%
  mutate(
    repeated_vals = list(make_ts(start_times))
  ) %>%
  unnest(c(data, repeated_vals)) %>%
  ungroup() %>%
  select(-start_times) %>%
  arrange(id, ts_start, ts_end)

usethis::use_data(periods_data, overwrite = TRUE)




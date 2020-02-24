
# Alright, let's see what we can do as far as formatting a table 1 more
# to our liking. I think I'm going to base this completely off the tableone
# package since that's what I'm most familiar with using.

# What should be our goals?

# 1. Round the ASDs to a particular digits
# 2. Remove the p-value and test
# 3. Format percents to 1 digit if < 10 and zero otherwise, disallow 100% when not 100%
# 4. Change mean/sd to have the +/- symbol
# 5. Figure out a way to effectively choose a number of digits to round to
# for the continuous variables.

# So what should the function take in as objects?
# 1. Wanted to take in a tableone object but there is some issue of losing
#    the row numbers when we get a ways into this.
# 2. Instead, let's just take in a tibble version of the print.tableone
#    For this experiement i used varlabels = TRUE, quote = FALSE,
#    noSpaces = TRUE, printToggle = FALSE, and smd = TRUE


format_tableone = function(t1, ...){

  # We know that ... should be character vectors so can just do:
  groups = c(...)

  # First thing to do is figure out what the summary measures are
  # for each variable.
  t1 = t1 %>%
    mutate(
      var_type = case_when(
        str_detect(Variable, 'mean \\(SD\\)') ~ 'normal',
        str_detect(Variable, 'median \\[IQR\\]') ~ 'nonnormal',
        str_detect(Variable, '=') ~ 'binary',
        str_detect(Variable, '\\(%\\)$') ~ 'nominal',
        TRUE ~ NA_character_
      ),
      var_type = fill_down(var_type),
      var_type = replace(
        var_type,
        str_detect(Variable, '[^=] \\(%\\)$') & var_type == 'nominal',
        NA_character_
      ),
      SMD = case_when(
        !is.na(as.numeric(SMD)) ~ format(round(as.numeric(SMD), 2), nsmall = 2),
        SMD == "<0.001" ~ "<0.01",
        TRUE ~ SMD
      )
    )

  # Replace plus and minus signs:
  plus_or_minus = function(x, type){
    ifelse(
      type %in% c('normal'),
      x %>%
        str_replace(
          ' \\(',
          ' ± '
        ) %>%
        str_replace(
          '\\)',
          ''
        ),
      x
    )
  }

  t1[groups] = lapply(
    t1[groups],
    plus_or_minus,
    t1[['var_type']]
  )

  # Now format the percents:
  fmt_percent = function(x, type){
    percents = x %>%
      str_extract(
        '\\([0-9]+\\.?[0-9]*\\)'
      ) %>%
      str_remove_all(
        '\\(|\\)'
      ) %>%
      as.numeric()
    percents = case_when(
      is.na(percents) ~ NA_character_,
      percents > 10 ~ format(round(percents), nsmall = 0),
      TRUE ~ format(round(percents, 1), nsmall = 1)
      ) %>%
      trimws()
    percents = paste0(
      str_extract(
        x,
        '^[0-9]+\\.?[0-9]* '
      ),
      '(',
      percents,
      ')'
    )
    ifelse(
      type %in% c('nominal', 'binary'),
      percents,
      x
    )

  }

  t1[groups] = lapply(
    t1[groups],
    fmt_percent,
    t1[['var_type']]
  )

  # Now the hardest part is figuring out a method of rounding the numeric
  # parts. Let's just start with something very easy to do which is to round
  # all the numbers greater than 10 to integers, between 1 and 10 to one digit
  # and then work with small digits ourselves.
  choose_digits = function(lower, upper){

    if(lower == upper){
      return(0)
    }

    logdiff = log10(upper - lower)

    # now we go through some cases:
    if(logdiff < 0){
      max(
        c(
          ceiling(-1*logdiff),
          2
        )
      )

    }
    else if(logdiff < 1){
      1
    }
    else{
      0
    }

  }


  # This one to just shorten a repeated chunk:
  round_format = function(x, digits){
    format(
      round(
        x,
        digits
      ),
      nsmall = digits
    )
  }


  round_numeric = function(x, var_type){
    print(x)
    # First distinguish between the normal and nonnormal cases:
    if(var_type %in%  c('normal')){

      point = str_extract(
        x,
        '[0-9]+\\.?[0-9]*'
      ) %>%
        as.numeric()
      sd = str_extract(
        x,
        ' [0-9]+\\.?[0-9]*'
      ) %>%
        as.numeric()

      digits = choose_digits(point-2*sd, point+2*sd)

      point = round_format(
        point,
        digits
      )
      sd = round_format(
        sd,
        digits
      )

      # I guess it's kinda redundant to change this back after we already
      # put in the plus minus but whatever
      paste0(
        point,
        ' ± ',
        sd
      )
    }
    else if(var_type %in%  c('nonnormal')){
      point = str_extract(
        x,
        '[0-9]+\\.?[0-9]*'
      ) %>%
        as.numeric()
      upper = str_extract(
        x,
        ' [0-9]+\\.?[0-9]*'
      ) %>%
        as.numeric()
      lower = str_extract(
        x,
        '[0-9]+\\.?[0-9]*,'
      ) %>%
        str_remove(
          ','
        ) %>%
        as.numeric()


      digits = choose_digits(lower, upper)

      point = round_format(
        point,
        digits
      )

      lower = round_format(
        lower,
        digits
      )

      upper = round_format(
        upper,
        digits
      )

      paste0(
        point,
        ' [',
        lower,
        ', ',
        upper,
        ']'
      )

    }
    else{
      x
    }

  }

  for(group in groups){

    t1[[group]] = Map(
      round_numeric,
      t1[[group]],
      t1[['var_type']]
    )

  }



  # Remove p-value, test, and type flag
  t1 %>%
    select(-p, -test, -var_type)

}


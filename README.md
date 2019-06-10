
IN PROGRESS (2019-06-05)!
=========================

**Stuff I'm working on right now:**

-   Working on dependencies. I don't want the package to attach anything when loaded so I have to go through and add dplyr:: to things
-   Trying to make a shiny gadget that helps you manually create crosswalks
-   Adding explainers in this file

<!-- README.md is generated from README.Rmd. Please edit that file -->
SvenR
-----

I like to pretend I'm a software developer so I created this little package. It's probably completely unneccessary as I frequently find better versions of the functions I write later. Creating a library is fun though, so maybe you will enjoy it too. I'll show some examples of what the code can do and what my ideas were behind it.

### Installation

Get it from [github](https://www.github.com/svenhalvorson/svenr):

``` r
devtools::install_github('svenhalvorson/svenr')
library('SvenR')
```

### Time Weighted Averages

Time weighted averages are a way of summarizing a numberical variable over many time points. Often it's useful when the measurements occur at irregular intervals. Basically we're multiplying the values by how long they occur for and then dividing by the total time. It's very similar to taking a Riemann sum.

Here's some example data:

|  id | val |          t          |
|:---:|:---:|:-------------------:|
|  1  |  4  | 2019-01-01 00:00:00 |
|  1  |  6  | 2019-01-01 00:10:00 |
|  1  |  8  | 2019-01-01 00:15:00 |
|  1  |  6  | 2019-01-01 00:45:00 |
|  2  |  1  | 2019-01-01 00:00:00 |
|  2  |  NA | 2019-01-01 00:10:00 |

The idea here is that have an **id** variable, a **val**ue variable, and two **t**ime variables. We want to summarize the value over time. There are three methods of counting the points that are supported: trapezoids and left/right endpoints.

Visually, the id \#1's values look like this:

<img src="man/figures/README-twa_types-1.png" style="display: block; margin: auto;" />

The time weighted average is the area in yellow divided by the total time (45 min). The methods will not compute very different totals if the number of data points is large but they can look different in a small data set like this.

The time weighted average using left endpoints is this:

<!-- $$\frac{4\cdot10+6\cdot5+8\cdot30}{45}=6.89$$ -->
Using the function:

``` r

twa(df = twa_ex, value_var = val, time_var = t, id, method = 'left')
#> # A tibble: 2 x 8
#>      id   twa total_time max_gap min_gap n_meas n_used  n_na
#>   <dbl> <dbl>      <dbl>   <dbl>   <dbl>  <int>  <int> <int>
#> 1     1  6.89         45      30       5      4      4     0
#> 2     2  1             0       0       0      2      1     1
```

You must supply the data frame to use, identify the time and value variables, list any id variables, and the method. The function computes the time weighted average across each combination of the ids, it tells you the total time used, the largest/smallest intervals (gap), the number of measures received, the number utilized, and the number missing.

Some notes:

-   Records with missing values or times are removed
-   If multiple records occur at the same time, the median is used
-   If only one record is given for a particular combination of ids, it is returned
-   Nonstandard evaluation is used for all arguments
-   You can supply a numeric, non-`POSIXct` time vector

I also allowed for computing this summary statistic relative to a reference value. The four `ref_dir` modes are as follows:

-   **Raw**: no alterations to the data
-   **Above x**: The distance above x is counted instead of the raw values. Values below x are counted as zeroes.
-   **Below x**: The converse of above.
-   **About x**: The absolute distance from x is used.

Here's an example of computing the time weighted average above 5:

``` r

twa(df = twa_ex, value_var = val, time_var = t, id, ref = 5, ref_dir = 'above', method = 'left')
#> # A tibble: 2 x 8
#>      id   twa total_time max_gap min_gap n_meas n_used  n_na
#>   <dbl> <dbl>      <dbl>   <dbl>   <dbl>  <int>  <int> <int>
#> 1     1  2.11         45      30       5      4      4     0
#> 2     2  1             0       0       0      2      1     1
```

<img src="man/figures/README-twa_above-1.png" style="display: block; margin: auto;" />

This is sometimes useful if you have a benchmark value you're trying to compare to. Note that it uses the entire 45 minutes as the denominator even though the first reading was set to zero because it is less than 5.

### Checking IDs

I often get data sets where I'm not sure if a set of variables uniquely identify observations, whether any set does, or if the count of specific variables has changed. I created two functions (so far) that help with this. These are mostly for interactive use.

The first is simply a count of unique values for some supplied variables:

``` r

count_ids(mtcars, cyl, carb)
#> [1] "32 observations"
#>   cyl carb
#> 1   3    6
```

We have 32 observations, 3 unique values for `cyl`, and 6 for `carb`. It's pipe-able so you can see what changes a function will cause:

``` r

mtcars = mtcars %>% 
  count_ids(cyl, carb) %>% 
  dplyr::filter(cyl > 4) %>% 
  count_ids(cyl, carb)
#> [1] "32 observations"
#>   cyl carb
#> 1   3    6
#> [1] "21 observations"
#>   cyl carb
#> 1   2    6
```

I often use this to make sure my merges are doing what I expect. The next function can either check if a combination of columns uniquely specify the observations or try and find a combination. Do `cyl` and `mpg` uniquely specify the cars in `mtcars`?

``` r

check_id(mtcars, cyl, mpg)
#> 
#> Key: cyl * mpg 
#>  Not unique within mtcars
#>  71.4% of rows are unique 
#>  6 non-unique rows
```

It will tell you if the combination you gave determines a specific row. You can also use it to try and search for a unique combination of variables by only supplying the data frame:

``` r

check_id(mtcars)
#> Unique keys(s) within mtcars:
#>  mpg * wt
#>  mpg * qsec
#>  cyl * qsec
#>  disp * qsec
#>  hp * qsec
#>  drat * qsec
#>  wt * qsec
#>  qsec * am
#>  qsec * gear
#>  qsec * carb
```

library(shiny)
library(miniUI)

myGadgetFunc <- function(inputValue1, inputValue2) {

  ui <- miniPage(
    gadgetTitleBar("My Gadget"),
    miniContentPanel(
      # Define layout, inputs, outputs
    )
  )

  server <- function(input, output, session) {
    # Define reactive expressions, outputs, etc.

    # When the Done button is clicked, return a value
    observeEvent(input$done, {
      returnValue <- ...
      stopApp(returnValue)
    })
  }

  runGadget(ui, server)
}


# Pseudo:

# manual_cross = function(df, grouping, all_combos = FALSE)

# take in data frame, find all distinct combinations of grouping variables (possibly non-existant ones)
# create a new column fill with one of the columns in grouping
# create the pane, allow editing of nrew column only
# insert a dput statement into the user's script of the cross table

crosswalk <- function(df, ..., all_combos = FALSE) {

  # get the dataframe name and grouping arguments
  df_name = enquo(df) %>%
    quo_name
  arguments = enquos(...)
  arguments_chr = arguments %>%
    map_chr(quo_name)
  new_col = paste0('new_', arguments_chr[1])


  # find distinct or expand
  dist_exp = ifelse(all_combos, expand, distinct)
  df = df %>%
    dist_exp(!!!arguments)
  # couldn't quite get the mutate to work ><
  df[new_col] = df[arguments_chr[1]]





  ui <- miniPage(
    gadgetTitleBar(paste0("Crosswalk for ", df_name)),
    miniContentPanel(
      # set up the hands on table:
      df %>%
        rhandsontable(readOnly = TRUE) %>%
        hot_col(new_col, readOnly = FALSE)
    )
  )

  server <- function(input, output, session) {
    # Define reactive expressions, outputs, etc.

    # When the Done button is clicked, return a value
    observeEvent(input$done, {
      returnValue <- ...
      stopApp(returnValue)
    })
  }

  runGadget(ui, server)
}

#' Create Crosswalk
#' @description Manually create a crosswalk from one or more columns of a data frame.
#' @param df A data frame
#' @param ... Coluumns within \code{df}
#' @param all_combos Should combinations of \code{...} not present in \code{df} be created?
#' @return Code to a rstudio script that generates the crosswalk.
#' @author Sven Halvorson
#' @details Often text data needs to be binned or converted. Doing this via
#' large sets of regular expressions sometimes works but often it's faster just
#' to make a crosswalk yourself. \code{crosswalk} creates the unique combination
#' of one or more columns within a data frame, allows the user to edit the 'new
#' values' and returns code to produce the crosswalk.
#'
#' You must highlight a single line within an R studio script for this to execute. This
#' is intended to help you not delete your code.
#' @export


crosswalk <- function(df, ..., all_combos = FALSE) {

  # So I decided that the first thing I should do is just try
  # and make sure that we're not overwriting peoples code so
  # let's look for where the cursor is and put on some guards
  selection = rstudioapi::getSourceEditorContext()$selection[[1]]$range
  left = selection$start[2]
  right = selection$end[2]
  top = selection$start[1]
  bottom = selection$start[1]
  highlight_text = rstudioapi::getSourceEditorContext()$content[selection$start[1]]

  # conditions to execute:
  highlight_portion = left != right & top == bottom
  highlight_single_line = left == right &  top == bottom
  contains_cross = stringr::str_detect(highlight_text, '[:blank:]*crosswalk\\(.+\\)[:blank:]*')

  if(!contains_cross | !(highlight_portion | highlight_single_line)){
    stop('Highlight only the crosswalk statement on a single line')
  }


  # get the dataframe name and grouping arguments
  df_name = dplyr::enquo(df) %>%
    (dplyr::quo_name)
  arguments = dplyr::enquos(...)
  arguments_chr = arguments %>%
    purrr::map_chr(dplyr::quo_name)
  new_col = paste0('new_', arguments_chr[1])

    # Check some things in case...
  if(any(!is.data.frame(df),
         sum(arguments_chr %in% colnames(df)) != length(arguments_chr))){
    stop('df must be a data frame and ... must be columns within df')
  }
  # Check if the columns are factors... doesn't work as well that way
  fct_check = df[arguments_chr] %>%
    purrr::map_lgl(is.factor)
  if(any(fct_check)){
    warning('Factors do not work as well as strings for this function')
  }

  # find distinct or expand
  dist_exp = ifelse(all_combos, dplyr::expand, dplyr::distinct)
  df = df %>%
    dist_exp(!!!arguments)
  # couldn't quite get the mutate to work ><
  df[new_col] = df[arguments_chr[1]]

  # This is the UI for the shiny gadget:
  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar(title = paste0("Crosswalk for ", paste(arguments_chr, collapse = ', '), ' in ', df_name),
                           right = miniUI::miniTitleBarButton("done", "Accept", primary = TRUE)),
    miniUI::miniContentPanel(
      rhandsontable::rHandsontableOutput('hot')
    )
  )

  server <- function(input, output, session) {
    # Define reactive expressions, outputs, etc.

    # When the Done button is clicked, return a value
    shiny::observeEvent(input$done, {
      returnValue <- rhandsontable::hot_to_r(input$hot)
      shiny::stopApp(returnValue)
    })

    # Show the handsontable:
    output$hot <- rhandsontable::renderRHandsontable({
      df %>%
        rhandsontable::rhandsontable(readOnly = TRUE) %>%
        rhandsontable::hot_col(new_col, readOnly = FALSE)
    })
  }

  # run the gadget
  out = shiny::runGadget(ui, server)

  # Now do some of that code formatting stuff we learned how to do with pipe_next
  # I think probably the best way for the user (me) to work with this is just to
  # call it on a blank line and then have the text inserted there
  doc_id = rstudioapi::getSourceEditorContext()$id

  # capture leading spaces
  lead_space = rep(' ', times = left-1) %>%
    paste(collapse = '')
  text = paste0(lead_space, df_name, '_cross = ', paste(deparse(out), collapse = ''))

  # put it into the editor
  rstudioapi::insertText(location = selection, text, id = doc_id)


}



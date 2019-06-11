#' @title Pipe to next line
#' @description Copy text on left of cursor, paste it on right of \code{=}, then add pipe to next line.
#'
pipe_next = function(){
  # here's how we can get the location of the cursor:
  selection = rstudioapi::getSourceEditorContext()$selection[[1]]$range
  left = selection$start
  right = selection$end
  doc_id = rstudioapi::getSourceEditorContext()$id

  # if they aren't on the same spot, don't do anything
  if(identical(left, right)){

    # coordiantes
    row = left[1]
    col = left[2]

    # text to copy
    text = rstudioapi::getSourceEditorContext()$content[row]
    text = substr(text, 1, col-1)
    # cut leading spaces:
    lead_space = stringr::str_extract(string = text, pattern = '^ *')
    text = stringr::str_remove(string = text, pattern = '^ *')
    text = paste0(' = ', text, ' %>% \n', lead_space, '  ')
    # insert it
    rstudioapi::insertText(location = selection, text, id = doc_id)
  }
}


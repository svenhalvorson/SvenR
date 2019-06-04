# These are some functions that are randomly selected by pretend_working

# Get a random wikipedia article
rand_wiki <- function(){

  message("Retreiving random Wikipedia article")
  for(i in 1:4){
    Sys.sleep(0.3)
    cat(".")
  }
  html <- xml2::read_html("http://en.wikipedia.org/wiki/Special:Random")
  title <- html %>%
    rvest:: html_nodes("#firstHeading") %>%
    rvest::html_text()
  cat("\n")
  message("Article: ", title)
  Sys.sleep(4)
  body <- html %>%
    rvest:: html_nodes("p") %>%
    rvest::html_text()
  # Now if we print the text of the body, it will come out in huge chunks so let's slow it down
  # and truncate it so less total text is printed
  body = body[body != ""]
  paragraphs = min(10, length(body))
  for(i in 1:paragraphs){
    cat(body[i])
    cat("\n\n")
    Sys.sleep(1.5)
  }
  if(length(body) > 10){
    message("WARNING: Article truncated")
  }

  return(body)
}

# See the latest stackoverflow.com posts
rand_stack <- function(){

  message("Maybe you can help these poor souls with some stack overflow questions?")
  cat("\n\n")
  tag = sample(c("R", "R", "R", "R",  "R",
                 "SAS", "STATA", "pandas",
                 "pandas", "google-apps-script"),
               size = 1)

  cat(paste("Here are the most recent", tag,  "questions from stackoverflow.com\n\n"))
  html <- xml2::read_html(paste0("https://stackoverflow.com/questions/tagged/",tag))
  questions = html %>%
    rvest::html_nodes(".question-hyperlink") %>%
    rvest::html_text()
  for(i in 1:10){
    cat(paste("\t",questions[i],"\n\n"))
    Sys.sleep(1.2)
  }

}

# random progress bar
progress_bar <- function(){
  total <- 20
  action = sample(x = c("Calibrating", "Examining", "Loading", "Deparsing", "Extracting", "Disturbing", "Intimidating", "Decimating", "Dispatching", "Systemtizing"), size = 1)
  adjective = sample(x = c("syrupy", "raw", "fragmented", "non-standard", "mythical", "lewd", "practical", "orthogonal", "ficticious", "large"), size = 1)
  noun = sample(x = c("data", "models", "progress monitors", "cake", "octopuses", "strings", "relationships", "bourgeoisie", "parameters", "pages", "subsets"), size = 1)
  notice = sample(x = c(". This may take some time...", "", ". One moment please...", ". Gimmie a minute...", ""), size = 1)
  print(paste0(action, " ", adjective, " ", noun, notice))
  # create progress bar
  pb <- txtProgressBar(min = 0, max = total, style = 3)
  for(i in 1:total){
    time = runif(n = 1, min = 0.1, max = 1.2)
    Sys.sleep(time)
    # update progress bar
    setTxtProgressBar(pb, i)
  }
  close(pb)
  # do it again 1/6th the time
  if(time < 0.25){
    message(paste("WARNING: Process halted. Error code",sample(100:999, size = 1), "Re-trying . . ."))
    progress_bar()
  }
}

# here's another version of the loading bar
flashy_bar <- function(){

  verbs = c("Truncating", "Proselytizing", "Disaggregating", "Finalzing", "Decoupling",
            "Casting", "Repairing", "Recyling", "Verifying", "Synthesizing", "Strong-arming",
            "Transposing", "P-hacking")
  adjectives = c("active", "normal", "uneven", "specious", "stranded", "overrated", "hyper",
                 "dark", "new", "special", "circular", "crusty", "heterogeneous", "misguided",
                 "inverted")
  nouns = c("water foul", "data frames", "maps", "coefficients", "metrics", "indicators", "deep dives",
            "coastlines", "New Mexicans", "diagrams", "priorities", "animations", "notifications",
            "statistics", "f-values", "correlations")

  times = sample(1:4, size = 1)
  for(i in 1:times){
    verb = sample(verbs, 1)
    adj = sample(adjectives, 1)
    noun = sample(nouns, 1)
    title = paste(verb,adj,noun)
    pb <- winProgressBar(title = paste(verb,adj,noun), min = 0,
                         max = 25, width = 500)

    for(i in 1:25){
      Sys.sleep(runif(n = 1, min = 0, max = 0.6))
      setWinProgressBar(pb, i, title=paste(title,"  ", round(i/25*100, 0),
                                           "% done"))
    }
    close(pb)
  }
}

# Maybe just a bunch of messages
buncha_messages <- function(){
  num_messages = sample(10:50, size = 1)
  nums1 = sample(1000:9999, size = num_messages)
  nums2 = sample(10:99, size = num_messages)
  let1 = sample(letters, size = num_messages, replace = TRUE)
  let2 = sample(letters, size = num_messages, replace = TRUE)
  let3 = sample(letters, size = num_messages, replace = TRUE)
  let4 = sample(letters, size = num_messages, replace = TRUE)
  names = paste0(nums1,let1, let2, let3, nums2, let4)

  object = sample(x = c("File", "Graph", "Iteration", "Matrix", "Worksheet", "Cell"), size = 1)
  verb = sample(x = c("imported", "deregulated", "parsed", "processed", "transformed", "interpolated", "refreshed"), size = 1)
  for(i in 1:num_messages){
    Sys.sleep(0.7)
    if(runif(n = 1) <0.03){
      message(paste0("WARNING: ", object, " ", names[i], " failed to be ", verb, ". Error code ", sample(100:999,1)))
    }
    else{
      print(paste0( object, " ", names[i], " successfully ", verb))
    }
  }
}

# Google headlines... note that it depends on their layout not changing much
headlines <- function(){
  message("Here are some of today's headlines:")
  html <- xml2::read_html("https://news.google.com/news/?ned=us&gl=US&hl=en")
  headlines = html %>%
    rvest::html_nodes('.DY5T1d') %>%
    rvest::html_text()

  for(i in (0:9)*5+1){
    cat(paste("\t",headlines[i],"\n\n"))
    Sys.sleep(1.3)
  }

}

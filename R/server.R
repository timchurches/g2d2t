shinyServer(function(input, output, session) {

  update_nlp_progress <- function(progress_obj,text, type) {
    progress_num <- NA
    progress_den <- NA
    try({vals <- strsplit(text,",")
         progress_num <- as.numeric(vals[[1]][1])
         progress_den <-as.numeric(vals[[1]][2])}, silent=TRUE)
    if (type == "trainer") {
      msg = 'Training of drug recogniser in progress:\n'
      dtl = paste("Drug name", progress_num, "of", progress_den)
    } else {
      msg = 'Recognising drug names in clinical trial descriptions:\n'
      dtl = paste("Trial", progress_num, "of", progress_den)
    }
    if (!is.na(progress_den) & progress_den != 0) { 
      if (progress_num == progress_den & type == "recogniser") {
        progress_obj$close()
        showModal(modalDialog(title = "NLP pre-processing completed!",
        "Drug names have been recognised and annotated in the relevent free-text fields for each clinical trial record."))
      } else {
        progress_obj$set(value = (progress_num / progress_den) * 10000,
                      message=msg, detail=dtl)
      }
    }
    invisible(NULL)
  }
  
  nlp_preprocessing <- function() {
    trainer_filename <- "/Users/tim.churches/g2d2t/data/trainer_progress.txt"
    recogniser_filename <- "/Users/tim.churches/g2d2t/data/recogniser_progress.txt"
    cat("0,0/n", file=trainer_filename)
    cat("0,0/n", file=recogniser_filename)
    trainer_progress_data <- reactiveFileReader(1000, session,
                                       trainer_filename, readLines)
    recogniser_progress_data <- reactiveFileReader(1000, session,
                                       recogniser_filename, readLines)
    progress <- Progress$new(session, min=1, max=10000)
    progress$set(message = 'Waiting to start...')

    observeEvent(trainer_progress_data(), 
               update_nlp_progress(progress, trainer_progress_data(), "trainer"))
               
    observeEvent(recogniser_progress_data(), 
               update_nlp_progress(progress, recogniser_progress_data(), "recogniser"))

    system2("/Users/tim.churches/anaconda/bin/python", args = "/Users/tim.churches/g2d2t/src/drug_matcher.py", wait=FALSE, invisible=TRUE)
  }
  
  observeEvent(input$NLP_button, nlp_preprocessing())
  
})

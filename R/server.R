shinyServer(function(input, output, session) {

  # Exit Shiny app if browser window/tab is closed by user
  session$onSessionEnded(stopApp)

  # initialise notifier
  progress <- Progress$new(session, min=1, max=10000)
  progress$set(message="Idle")

  # database connection
  dbdir <- "playground/MonetDBLite"
  dbcon <- DBI::dbConnect(MonetDBLite::MonetDBLite(), dbdir)

  # code for loading the ANZCTR XML files
  source("read_anzctr_xml_funcs.R")
  anzctr_xmlpath <- "/Users/tim.churches/g2d2t/data/anzctr_xml"

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
      progress_obj$set(value = (progress_num / progress_den) * 10000,
                      message=msg, detail=dtl)
    }
    invisible(NULL)
  }

  nlp_preprocessing <- function() {
    trainer_filename <- "/Users/tim.churches/g2d2t/data/trainer_progress.txt"
    recogniser_filename <- "/Users/tim.churches/g2d2t/data/recogniser_progress.txt"
    writeLines("0,0", con=trainer_filename)
    writeLines("0,0", con=recogniser_filename)
    trainer_progress_data <- reactiveFileReader(500, session,
                                       trainer_filename, readLines)
    recogniser_progress_data <- reactiveFileReader(500, session,
                                       recogniser_filename, readLines)
    progress$set(message = 'Initialising NLP pre-processing...')

    observeEvent(trainer_progress_data(), 
               update_nlp_progress(progress, trainer_progress_data(), "trainer"))
               
    observeEvent(recogniser_progress_data(), 
               update_nlp_progress(progress, recogniser_progress_data(), "recogniser"))

    system2("/Users/tim.churches/anaconda/bin/python", args = "/Users/tim.churches/g2d2t/src/drug_matcher.py", wait=FALSE, invisible=TRUE)
  }

  nlp_status_file <- "/Users/tim.churches/g2d2t/data/nlp_status.txt"
  nlp_feather_file <- "/Users/tim.churches/g2d2t/data/recognised_drug_names.feather"
  
  ingest_nlp_preprocessing <- function(progress_obj, dbcon) {
    # check that we have finished and the data are ready to read
    if (file.exists(nlp_status_file)) {
      nlp_status <- as.numeric(readLines(nlp_status_file))[1]
    } else {
      nlp_status <- 0
    }
    if (nlp_status == 1) {
      # read the new data
      new_nlp_data <- feather::read_feather(nlp_feather_file)
      DBI::dbWriteTable(dbcon, "recognised_drugs", new_nlp_data, overwrite=TRUE)
      # remove the feather file
      unlink(nlp_feather_file)
      # reset the status file
      unlink(nlp_status_file)
      writeLines("0", con=nlp_status_file)
      # close the progress notification
      progress_obj$close()
      # inform the user
      showModal(modalDialog(title = "NLP pre-processing completed!",
        "Drug names have been recognised and annotated in the relevent free-text fields for each clinical trial record."))
      # re-enable the NLP preprocessing button
      updateActionButton(session, "NLP_button", label = "Perform NLP pre-processing")
      shinyjs::enable("NLP_button")
    }
  }

  NLP_ready <- reactivePoll(1000, session,
    checkFunc = function() {
      if (file.exists(nlp_status_file))
        file.info(nlp_status_file)$mtime[1]
      else
        ""
    },
    # This function returns the content of the semaphore file
    valueFunc = function() {
      if (file.exists(nlp_status_file))
        return(as.numeric(readLines(nlp_status_file))[1])
      else
        return(0)
    }
  )

  observeEvent(NLP_ready(), ingest_nlp_preprocessing(progress, dbcon))

  observeEvent(input$ingest_button, {
    updateActionButton(session, "ingest_button", label = "Ingesting ANZCTR XML files...")
    shinyjs::disable("ingest_button")
    ingest_anzctr_xml(xmlpath=anzctr_xmlpath, dbcon=dbcon, progress_obj=progress)
    # re-enable the ingest button
    updateActionButton(session, "ingest_button", label = "Ingest ANZCTR XML files")
    shinyjs::enable("ingest_button")
  })
      
  observeEvent(input$NLP_button, {
    updateActionButton(session, "NLP_button", label = "NLP pre-processing in progress...")
    shinyjs::disable("NLP_button")
    nlp_preprocessing()
  })

  # quit tab
  observeEvent(input$quit_and_close, {
    js$closeWindow()
    stopApp()
  }) 
  
})

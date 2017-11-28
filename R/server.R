shinyServer(function(input, output, session) {

  trainer_filename <- "/Users/tim.churches/g2d2t_data/trainer_progress.txt"
  recogniser_filename <- "/Users/tim.churches/g2d2t_data/recogniser_progress.txt"
  nlp_status_file <- "/Users/tim.churches/g2d2t_data/nlp_status.txt"
  nlp_feather_file <- "/Users/tim.churches/g2d2t_data/recognised_drug_names.feather"
  interventions_feather_file <- "/Users/tim.churches/g2d2t_data/interventions.feather"
  drug_names_feather_file <- "/Users/tim.churches/g2d2t_data/drug_names.feather"
  # anzctr_download_shell_file <- "/Users/tim.churches/g2d2t/R/fetch_all_anzctr2.sh"
  anzctr_download_file <- "/Users/tim.churches/g2d2t_data/anzctr_xml.zip"
  dbdir <- "/Users/tim.churches/g2d2t_data/MonetDBLite"
  anzctr_xmlpath <- "/Users/tim.churches/g2d2t_data/anzctr_xml"
  
  # Exit Shiny app if browser window/tab is closed by user
  session$onSessionEnded(stopApp)

  # database connection
  dbcon <- DBI::dbConnect(MonetDBLite::MonetDBLite(), dbdir)

  # code for fetching ANZCTR XML files
  source("httr_fetch_anzctr.R")
  # code for loading the ANZCTR XML files
  source("read_anzctr_xml_funcs.R")
  # code for fetch and loading the DrugBank files
  source("fetch_DrugData.R")
  source("passwords.R")

  # utilities
  source("utils.R")

  # Initialise DrugBank data 
  drugbank_status_text <- load_drugbank_dfs(drugbank_df_names, dbcon)

  update_nlp_progress <- function(progress_obj, text, type) {
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

  nlp_preprocessing <- function(progress_obj) {
    writeLines("0,0", con=trainer_filename)
    writeLines("0,0", con=recogniser_filename)
    # update the notifier
    progress_obj$set(message="Initialising NLP pre-processing...")
    # monitor the progress files    
    trainer_progress_data <- reactiveFileReader(500, session,
                                       trainer_filename, readLines)
    recogniser_progress_data <- reactiveFileReader(500, session,
                                       recogniser_filename, readLines)

    tp <- observeEvent(trainer_progress_data(), 
               update_nlp_progress(progress_obj, trainer_progress_data(), "trainer"))
               
    rp <- observeEvent(recogniser_progress_data(), 
               update_nlp_progress(progress_obj, recogniser_progress_data(), "recogniser"))

    # need to re-write (freshen) the feather interchange file here
    # first reload the data from the database
    load_anzctr_dfs(dbcon)
    load_drugbank_dfs(drugbank_df_names, dbcon)
    # now write the feather interchange files
    feather::write_feather(anzctr_core %>% select(trial_number, interventions), interventions_feather_file)  
    feather::write_feather(drug_terms2drug_id %>% select(drug_id, term), drug_names_feather_file)
    system2("/Users/tim.churches/anaconda/bin/python", args = "/Users/tim.churches/g2d2t/src/drug_matcher.py", wait=FALSE, invisible=TRUE)
  }

  ingest_nlp_preprocessing <- function(nlp_observer, progress_obj, dbcon) {
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
      nlp_observer$destroy()
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

  observeEvent(input$download_anzctr_button, {
    updateActionButton(session, "download_anzctr_button", label = "Downloading ANZCTR XML files...")
    shinyjs::disable("download_anzctr_button")
    progress_obj <- Progress$new(session, min=0, max=10000) 
    progress_obj$set(message="Downloading ANZCTR XML files...") 
    # ensure any existing download file is deleted
    unlink(anzctr_download_file)
    rc <- fetch_anzctr_xml_zip_file(outfile=anzctr_download_file, progress_obj=progress_obj)
    progress_obj$set(message="Unpacking the downloaded ANZCTR XML files...") 
    # remove the existing XML directory
    unlink(anzctr_xmlpath, recursive = TRUE)
    # unzip the downladed file to the target directory
    unzip_results <- myTryCatch(unzip(anzctr_download_file, exdir=anzctr_xmlpath))
    if (!is.null(unzip_results$warning)) {
      # inform the user
      showModal(modalDialog(title = "There was a problem downloading and/or unpacking the ANZCTR XML files.",
        "Please check your internet connection, and/or try again later. You could also access this page in your web browser and click the DOWNLOAD button to check that downloads are currently operational from the ANZCTR web site: http://www.anzctr.org.au/TrialSearch.aspx?searchTxt=&isBasic=True"))
    } else {
      status_df <- data.frame(status=paste(format(length(list.files(path=anzctr_xmlpath, pattern=glob2rx("*.xml"))), big.mark=","),  "ANZCTR XML files were last downloaded and stored at", format(Sys.time(), "%I:%M%p", tz="Australia/Sydney"), "on",  format(Sys.time(), "%a %d %b %Y", tz="Australia/Sydney")))
      DBI::dbWriteTable(dbcon, "anzctr_download_status", status_df, overwrite=TRUE)
    }  
    # delete the downloaded zip file and the semaphore
    unlink(anzctr_download_file)
    # re-enable the ingest button
    shinyjs::enable("download_anzctr_button")
    updateActionButton(session, "download_anzctr_button", label = "Download ANZCTR XML files")
    progress_obj$close()
  })
  
  
  observeEvent(input$ingest_button, {
    progress_obj <- Progress$new(session, min=1, max=10000)
    progress_obj$set(message="Initialising ingestion of ANZCTR XML files...")
    updateActionButton(session, "ingest_button", label = "Ingesting ANZCTR XML files...")
    shinyjs::disable("ingest_button")
    Sys.sleep(1.5)
    ingest_anzctr_xml(xmlpath=anzctr_xmlpath, dbcon=dbcon, progress_obj=progress_obj)
    # re-looad the data
    load_anzctr_dfs(dbcon)
    # re-enable the ingest button
    shinyjs::enable("ingest_button")
    updateActionButton(session, "ingest_button", label = "Ingest ANZCTR XML files")
    progress_obj$close()
  })
      
  observeEvent(input$NLP_button, {
    progress_obj <- Progress$new(session, min=1, max=10000)
    updateActionButton(session, "NLP_button", label = "NLP pre-processing in progress...")
    shinyjs::disable("NLP_button")
    # create observer for completion flag
    nr <- observeEvent(NLP_ready(), ingest_nlp_preprocessing(nr, progress_obj, dbcon))
    nlp_preprocessing(progress_obj)
  })

  observeEvent(input$get_drugbank_data_button, {
    updateActionButton(session, "get_drugbank_data_button", label = "Downloading of DrugBank.ca data in progress...")
    shinyjs::disable("get_drugbank_data_button")
    progress_obj <- Progress$new(session, min=1, max=10000)
    drugbank_fetches <- get_drugbank("everything", username=drugbank_username, password=drugbank_password, progress_obj=progress_obj)
    progress_obj$set(value=NULL, message="Storing the Drugbank.ca data files...")
    create_drugbank_data_frames(drugbank_fetches)
    wrangle_drugbank_data()
    store_drugbank_dfs(drugbank_df_names, dbcon)
    load_drugbank_dfs(drugbank_df_names, dbcon)
    progress_obj$close()
    showModal(modalDialog(title = "DrugBank.ca files updated.",
        paste("DrugBank.ca release", latest_drugbank_release, "files have been downloaded, processed and loaded into the database.")))
    shinyjs::enable("get_drugbank_data_button")
    updateActionButton(session, "get_drugbank_data_button", label = "Download DrugBank.ca files")
    progress_obj$close()
  })

  output$drugbank_data_status <- renderText({
    input$get_drugbank_data_button
    
    paste(isolate(load_drugbank_dfs(drugbank_df_names, dbcon)),".",
    "\nThe latest available release is ", get_latest_drugbank_release(),".", sep="")
  })  

  output$anzctr_download_status <- renderText({
    input$download_anzctr_button
    
    get_anzctr_download_status(dbcon)
  })  

  output$anzctr_ingest_status <- renderText({
    input$ingest_button
    
    load_anzctr_dfs(dbcon)
  })  
      
  # quit tab
  observeEvent(input$quit_and_close, {
    js$closeWindow()
    stopApp()
  }) 

})

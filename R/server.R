shinyServer(function(input, output, session) {
  
  # Exit Shiny app if browser window/tab is closed by user
  session$onSessionEnded(stopApp)


  # Initialise DrugBank data 
  drugbank_status_text <- load_drugbank_dfs(drugbank_df_names, dbcon)
  # Initialise ANZCTR data
  status_text <- load_anzctr_dfs(dbcon)
  # Initialise anzctr2drug
  anzctr2drug <-DBI::dbReadTable(dbcon, "recognised_drugs")
  # Update trial browser span
  updateNumericInput(session, "trial_num", label = NULL, value = 1, min=1, max=nrow(anzctr_core), step=1)

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
      anzctr2drug <- feather::read_feather(nlp_feather_file)
      assign("anzctr2drug", anzctr2drug, envir=parent.frame())
      instances_drugs_recognised <- anzctr2drug %>% nrow()
      num_drugs_recognised <- anzctr2drug %>% distinct(drug_id) %>% nrow()
      num_trials_with_recognised_drugs <- anzctr2drug %>% distinct(trial_number) %>% nrow()
      num_trials <- anzctr_core %>% nrow()
      status_df <- tibble(status=paste(format(instances_drugs_recognised, big.mark=","), "mentions of", format(num_drugs_recognised, big.mark=","), "distinct drugs were recognised in", format(num_trials_with_recognised_drugs, big.mark=","), "out of", format(num_trials, big.mark=","), "clinical trial records."))
      DBI::dbWriteTable(dbcon, "recognised_drugs", anzctr2drug, overwrite=TRUE)
      DBI::dbWriteTable(dbcon, "nlp_preprocessing_status", status_df, overwrite=TRUE)
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

  # quit tab
  observeEvent(input$quit_and_close, {
    js$closeWindow()
    stopApp()
  }) 

    output$drugbank_data_status <- renderText({
    input$get_drugbank_data_button
    
    paste(isolate(load_drugbank_dfs(drugbank_df_names, dbcon)),".",
    " The latest available release is ", isolate(get_latest_drugbank_release()),".", sep="")
  })  

  output$anzctr_download_status <- renderText({
    input$download_anzctr_button
    
    paste(get_anzctr_download_status(dbcon), ".",
          " The current number of trials registered with ANZCTR is ", format(isolate(get_current_number_anzctr_trials()), big.mark=","), ".", sep="")
  })  

  output$anzctr_ingest_status <- renderText({
    input$ingest_button
    
    isolate(load_anzctr_dfs(dbcon))
  })  

  get_nlp_proprocessing_status <- function(dbcon) {
  status_text <- ""
  status_text <- try(as.character(as.tibble(DBI::dbReadTable(dbcon, "nlp_preprocessing_status"))[1,"status"]))
  return(status_text)
}

  output$nlp_preprocessing_status <- renderText({
    get_nlp_proprocessing_status(dbcon)
      
  })  

  do_drug_search <- function() {
    trial_search_results <- drug_terms2drug_id %>% mutate(term_lower = tolower(term)) %>% filter(term_lower==tolower(input$search_drug_name)) %>% left_join(anzctr2drug, by="drug_id") %>% distinct(trial_number)
    return(trial_search_results)
  }
 
  get_current_search_result_trial <- function(trial_search_results) {
    if (nrow(trial_search_results) > 0) {
      updateNumericInput(session, "result_num", min=1, max=nrow(trial_search_results), step=1)
      current_trial <- trial_search_results[input$result_num,]$trial_number
    } else {
      current_trial <- NULL
    }
    return(current_trial)  
  }
  
  update_search_output_fields <- function(current_trial, trial_search_results) {
    output$num_search_results <- renderText(paste(input$result_num,"of",nrow(trial_search_results)))
    # print(current_trial)
    if (!is.null(current_trial)) {
      anzctr_id <- anzctr_core[anzctr_core$trial_number == current_trial,]$trial_number
      b <- anzctr2drug %>% filter(trial_number == anzctr_id) %>% arrange(desc(start_char))
      # current_trial <- input$pager$page_current
      # anzctr_core[input$search_results_pager$page_current,]$interventions
      output$search_trial_id <- renderText({current_trial})
      output$search_scientific_title <- renderUI({anzctr_core[anzctr_core$trial_number == current_trial,]$scientific_title})
      a <- anzctr_core[anzctr_core$trial_number == current_trial,]$interventions
      # a <- gsub("\n", "", a)
      if (nrow(b) > 0) {
        for (i in 1:nrow(b)) {
          span_start <- b[i,]$start_char
          span_end <- b[i,]$end_char
          drug_id <- b[i,]$drug_id
          # a <- paste(stringr::str_sub(a,1,span_start-1), "<span style='color:red' class='drug' id='", drug_id, "'>", stringr::str_sub(a,span_start,span_end), "<span style='color:orange'> (", drug_id, ")</span></span>", stringr::str_sub(a,span_end + 1), sep="")
          a <- paste(stringr::str_sub(a,1,span_start-1), "<span style='color:red' class='drug' id='", drug_id, "'>", stringr::str_sub(a,span_start,span_end), "<span style='color:orange'> (<a href='https://www.drugbank.ca/drugs/", drug_id,"' target='_blank'>", drug_id, "</a>)</span></span>", stringr::str_sub(a,span_end + 1), sep="")
        }
      }
      output$search_interventions <- renderUI(HTML(gsub("\\|", "<br />", gsub(" \\| ", "<br />", a))))
      # HTML(a)
    } else {
      output$search_interventions <- renderUI(NULL)
    }
    return(NULL)
  }
  
  observeEvent(input$drug_search_button, {
    trial_search_results <- do_drug_search()
    current_trial <- get_current_search_result_trial(trial_search_results)
    update_search_output_fields(current_trial, trial_search_results)
  }) 

  observeEvent(input$result_num, {
    trial_search_results <- do_drug_search()
    current_trial <- get_current_search_result_trial(trial_search_results)
    update_search_output_fields(current_trial, trial_search_results)
  }) 

})

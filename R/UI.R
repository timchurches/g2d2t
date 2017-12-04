library(shiny)
library(shinyjs)

source("shinyjs_helpers.R") # Load all the code needed to show feedback on a button click
jscode <- "shinyjs.closeWindow = function() { window.close(); }"

shinyUI(navbarPage("g2d2t", collapsible = TRUE,
  tabPanel("Data",
    fluidRow(
      column(4, offset=1,
        actionButton("get_drugbank_data_button", "Download DrugBank.ca files", class = "btn-primary", width="300px")
      ),
      column(6, textOutput("drugbank_data_status"))
    ),
    fluidRow(p()),
    fluidRow(
      column(4, offset=1,
        actionButton("download_anzctr_button", "Download ANZCTR XML files", class = "btn-primary", width="300px")
      ),
    column(6, textOutput("anzctr_download_status"))
    ),
    fluidRow(p()),
    fluidRow(
      column(4, offset=1,
        actionButton("ingest_button", "Ingest ANZCTR XML files", class = "btn-primary", width="300px")
      ),
      column(6, textOutput("anzctr_ingest_status"))
    ),
    fluidRow(p()),
    fluidRow(
      column(4, offset=1,
        actionButton("NLP_button", "Perform NLP pre-processing", class = "btn-primary", width="300px")
      ),
      column(6, textOutput("nlp_preprocessing_status"))
    )
  ),
  tabPanel("Search",
    fluidRow(
      column(6, offset=1, textInput("search_drug_name", label="Drug", value="", placeholder="aspirin"))
    ),
    fluidRow(p()),
    fluidRow(
      column(4, offset=1, textOutput("search_trial_id"),
      column(4,  numericInput("result_num", label="Result No.", value=1, min=1, max=1, step=1))
)
    ),
    fluidRow(p()),
    fluidRow(
      column(11, offset=1,
        htmlOutput('search_interventions')  
      )
    ),
    fluidRow(p()),
    fluidRow(
      column(11, offset=1,
        verbatimTextOutput('search_debug')  
      )
    )
  ),
  tabPanel("Browse",
    fluidRow(
      column(6, offset=1, numericInput("trial_num", label="Trial No.", value=1, min=1, max=20000, step=1))
    ),
    fluidRow(p()),
    fluidRow(
      column(11, offset=1, textOutput("browse_trial_id"))
    ),
    fluidRow(p()),
    fluidRow(
      column(11, offset=1,
        htmlOutput('browse_interventions')  
      )
    ),
    fluidRow(p()),
    fluidRow(
      column(11, offset=1,
        verbatimTextOutput('debug')  
      )
    )
  ),
  tabPanel("About"),
  tabPanel("Quit",
    useShinyjs(),
    extendShinyjs(text = jscode, functions = c("closeWindow")),
    column(6, offset=1,
      actionButton("quit_and_close", "Quit the app and close the browser window/tab", 
                 icon=icon("window-close"), class="btn btn-danger")
    )
  )
))


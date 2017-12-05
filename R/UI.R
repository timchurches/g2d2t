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
      column(3, offset=1, textInput("search_drug_name", label=NULL, value="", placeholder="aspirin")),
      column(2, actionButton("drug_search_button", " Search", class = "btn btn-info glyphicon glyphicon-search", with="300px"))
    ),
    fluidRow(p()),
    fluidRow(
      column(4, offset=1, textOutput("num_search_results")),
      column(4,  numericInput("result_num", label="Result No.", value=1, min=1, max=1, step=1)),
      column(3, textOutput("search_trial_id"))
    ),
    fluidRow(p()),
    fluidRow(
      column(12, 
        wellPanel(id="search_output", style = "overflow-y:scroll; max-height: 600px",
          fluidRow(
            column(1, "Scientific title"),
            column(11, wellPanel(id="scientific_title_text", htmlOutput('search_scientific_title')))
          ),
          fluidRow(
            column(1, "Intervention(s)"),
            column(11, wellPanel(id="interventions_text", htmlOutput('search_interventions')))
          )
        ) 
      )
    ),
    fluidRow(p()),
    fluidRow(
      column(11, offset=1,
        verbatimTextOutput('search_debug')  
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


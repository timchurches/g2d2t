library(shiny)
library(shinyjs)

source("shinyjs_helpers.R") # Load all the code needed to show feedback on a button click
jscode <- "shinyjs.closeWindow = function() { window.close(); }"

shinyUI(navbarPage("g2d2t", collapsible = TRUE,
  tabPanel("Data",
    fluidRow(
      column(6, offset=1,
        actionButton("get_drugbank_data_button", "Download DrugBank.ca files", class = "btn-primary", width="300px")
      )
    ),
    fluidRow(p()),
    fluidRow(
      column(6, offset=1,
        actionButton("download_anzctr_button", "Download ANZCTR XML files", class = "btn-primary", width="300px")
      )
    ),
    fluidRow(p()),
    fluidRow(
      column(6, offset=1,
        actionButton("ingest_button", "Ingest ANZCTR XML files", class = "btn-primary", width="300px")
      )
    ),
    fluidRow(p()),
    fluidRow(
      column(6, offset=1,
        actionButton("NLP_button", "Perform NLP pre-processing", class = "btn-primary", width="300px")
      )
    )
  ),
  tabPanel("Search"),
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


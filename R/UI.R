library(shiny)
library(shinyjs)

source("shinyjs_helpers.R") # Load all the code needed to show feedback on a button click
jscode <- "shinyjs.closeWindow = function() { window.close(); }"

shinyUI(navbarPage("g2d2t",
  tabPanel("Data",
    fluidRow(
        actionButton("ingest_button", "Ingest ANZCTR XML files", class = "btn-primary")
    ),
    fluidRow(
        actionButton("NLP_button", "Perform NLP pre-processing", class = "btn-primary")
    )
  ),
  tabPanel("Search"),
  tabPanel("About"),
  tabPanel("Quit",
    useShinyjs(),
    extendShinyjs(text = jscode, functions = c("closeWindow")),
    actionButton("quit_and_close", "Quit the app and close the browser window/tab", 
                 icon=icon("window-close"), class="btn btn-danger")
  )
))


library(shiny)

file_name <- "/Users/tim.churches/g2d2t/data/trainer_progress.txt"
bkg_color <- "red"

# Define UI for application
ui <- fluidPage(
      titlePanel("title panel"),
      tableOutput('table')
)

# Define server logic required
server <- function(input, output, session) {
  # observe the raw file, and refresh if there is change every 5 seconds
  # system2("/Users/tim.churches/anaconda/bin/python", args="/Users/tim.churches/g2d2t/src/matcher_test2.py", wait=FALSE)
  prog_data <- reactiveFileReader(5000, session, file_name, readFunc=read.file)
  output$table <- renderTable({prog_data()})      
}

# Run the application 
shinyApp(ui = ui, server = server)

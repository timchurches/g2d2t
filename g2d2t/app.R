library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("g2d2t - genes-to-drugs-to-trials"),
   
   # Sidebar with search input field 
   sidebarLayout(
      sidebarPanel(
          textInput("search_terms",
                    "Search terms",
                    value = "",
                    placeholder = "Enter gene names or symbols here"),
          submitButton("Search", icon("search")),
          verbatimTextOutput("value")
      ),
      
      # Show trial records
      mainPanel(
         textOutput("search_terms")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   output$search_terms <- renderText(input$value)
}

# Run the application 
shinyApp(ui = ui, server = server)


shinyUI(navbarPage("g2d2t",
  tabPanel("Data",
    fluidRow(
      column(12,
        p("This page does drug recognition on the free text.")
      )
    ),
    fluidRow(
      actionButton("NLP_button", "NLP pre-processing")
    )
  ),
  tabPanel("Search"),
  tabPanel("About")
))


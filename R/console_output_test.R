foo <- function() {
  message("one")
  Sys.sleep(1.5)
  message("two")
  Sys.sleep(1.5)
  message("three")
  Sys.sleep(1.5)
  message("four")
  Sys.sleep(1.5)
  message("five")
  Sys.sleep(1.5)
  message("six")
}

shinyApp(
  ui = fluidPage(
    shinyjs::useShinyjs(),
    actionButton("btn","Click me"),
    textOutput("text")
  ),
  server = function(input,output, session) {
    observeEvent(input$btn, {
      withCallingHandlers({
        shinyjs::html("text", "")
        foo()
      },
        message = function(m) {
          shinyjs::html(id = "text", html = m$message, add = TRUE)
      })
    })
  }
)

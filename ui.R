#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  
  fluidRow(column(4, h1(strong("Text Prediction: Kneser Ney")))),
  fluidRow(column(12, p("This uses tables generated using the", a(href="https://en.wikipedia.org/wiki/Kneser%E2%80%93Ney_smoothing", "Kneser-Ney"), "smoothing model to predict the next word in a phrase typed
                        by the user."),
                  p("Please see", a(href="http://rpubs.com/jelowey/capstonepresentation", "presentation"),"for more information and instructions."),
                  p("The application takes a moment to load, it will notify you when ready. Please note that if you hit input while there is a trailing ' ' at the end of your input, you're more likely to get an incorrect result"),
  fluidRow(column(12,align = "center",
                  h2(strong("Input")),
                  textInput("textinput", label=NULL,value=NULL, placeholder = "Enter text...")
                  )
  ),
  fluidRow(column(12, align= "center",
                  h4(textOutput("readyornot"))
                  
  
  )),
  fluidRow(column(12, align = "center",
           actionButton("submit", label="Submit")
  )),
  fluidRow(column(12, align="center",
                  h3("Prediction:"))),
  fluidRow(column(12, align="center",
                  textOutput("prediction")),
  tags$head(tags$style("#prediction{color: purple;
                                    font-size: xx-large;
                                    font-style: bold;}"
                       ))
  ))
)))
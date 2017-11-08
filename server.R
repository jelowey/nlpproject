#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  library(data.table)
  library(stringr)
  library(readr)
  ready <- FALSE
  output$readyornot <- renderText({
    if(ready == TRUE){
      { "READY"}
    }
    else{"NOT READY"}
  })
  unigramDF <- read_csv("unigramDF.csv")
  bigramsDF <- read_csv("bigramsDF.csv")
  trigramsDF <- read_csv("trigramsDF.csv")
  quadgramsDF <- read_csv("quadgramsDF.csv")
  unigramDF <- as.data.table(unigramDF)
  bigramsDF <- as.data.table(bigramsDF)
  trigramsDF <- as.data.table(trigramsDF)
  quadgramsDF <- as.data.table(quadgramsDF)
  ready <- TRUE
  getLastWords <- function(string, words) {
    pattern <- paste("[a-z']+( [a-z']+){", words - 1, "}$", sep="")
    return(substring(string, str_locate(string, pattern)[,1]))
  }
  predictor <- function(input) {
    if(is.null(input)){return("No text entered")}
    else{
    n <- length(strsplit(input, " ")[[1]])
    prediction <- c()
    if(n >= 3 && length(prediction)<3)
      prediction <- c(prediction, quadgramsDF[FirstWords == getLastWords(input,3)]$LastWord)
    if(n >= 2 && length(prediction)<3)
      prediction <- c(prediction, trigramsDF[FirstWords == getLastWords(input,2)]$LastWord)
    if(n >= 1 && length(prediction)<3)
      prediction <- c(prediction, bigramsDF[FirstWords == getLastWords(input,1)]$LastWord)
    if(length(prediction)<3 ) prediction <- c(prediction, unigramDF$Words)
    
    return(unique(prediction)[1:3])}

    
  }
  string <-"No text entered"
  string <- eventReactive(input$submit,{paste0(predictor(input$textinput),collapse=", ")})
  
  
  output$prediction <- renderText({string()})
})


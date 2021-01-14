library(readr)
library(shiny)
library(GGally)
source("utils.R",   encoding = 'UTF-8')
mydata <- read.csv("data.csv")
shinyApp(
  ui <- tabPanel("Univariado",fluidPage(titlePanel("Univariado"), tags$style(HTML('body {font-family:"Palatino",Georgia,Serif; background-color:#fffff8 }')),
                                        sidebarLayout(
                                          sidebarPanel(
                                            uiOutput(outputId = "aa")
                                          ),
                                          mainPanel(textOutput("a"),
                                                    verbatimTextOutput("summary"),
                                                    plotOutput("plot", click = "plot_click")
                                          )
                                        )
  )),
  server <- function(input,output) {
    
    output$aa <- renderUI({
      selectInput(inputId = "aa2", 
                  label="Selecciona una variable para analizar:",
                  choices = colnames(mydata))
    })
    
    
    mysubsetdata <- eventReactive(input$aa2,{
      mydata[[input$aa2]]
    })
    
    output$summary <- renderPrint({
      summary(mysubsetdata())
    })
    
    output$plot <- renderPlot({
      general(mydata,mysubsetdata())
    })
  }, options = list(height = 650))
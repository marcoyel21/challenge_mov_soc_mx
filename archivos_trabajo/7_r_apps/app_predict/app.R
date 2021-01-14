
library(MASS)
library(readr)
library(shiny)


# creation of dummy data and model

getwd()
df<-read_csv("sample.csv")
model <- polr(factor(objetivo) ~ p05+ factor(p06)+ factor(p09_1)
              + factor(p10_1)+ estatura
              + p21+ factor(p23)+ factor(p24)+ p28+ p38_11+ factor(p43)+
                p38m_11+ factor(p43m)+ p60+ p61+
                p64+ p86+ p87+ p98+
                p122+ p131+ p132+ p142+ p143+ p144+ 
                factor(p151)+ factor(region) +  factor(escolaridadh)+indigena, 
              df, method = c("probit"))

ui = fluidPage(
    # this is an input object   
    titlePanel("Calcula tu décil"), tags$style(HTML('body {font-family:"Palatino",Georgia,Serif; background-color:#fffff8 }')),
    sidebarLayout(position = "left",
                  sidebarPanel(
                    numericInput(inputId='p05', label='1. Edad', value = 40,min = 25, max = 65, step = NA,width = NULL),
                    numericInput(inputId='p06', label='2. Sexo', value = 1,min = 1, max = 2, step = NA,width = NULL),
                    numericInput(inputId='p09_1', label='3. Hospital al que acude', value = 1,min = 1, max = 11, step = NA,width = NULL),
                    numericInput(inputId='p10_1', label='4. ¿Tiene derechos a servicios médicos?', value = 1,min = 8, max = 2, step = NA,width = NULL),
                    numericInput(inputId='estatura', label='5. Estatura en cm', value = 160,min = 130, max = 193, step = NA,width = NULL),
                    numericInput(inputId='p21', label='6. Peso en kg', value = 70,min = 42, max = 149, step = NA,width = NULL),
                    numericInput(inputId='p23', label='7. Entidad en la que vivía a los 18 años', value = 17,min = 32, max = 2, step = NA,width = NULL),
                    numericInput(inputId='p24', label='8. Percepción del tamaño de su localidad', value = 3,min = 1, max = 5, step = NA,width = NULL),
                    numericInput(inputId='p28', label='9. Cuartos en el hogar(contando la cocina) cuando niño', value = 4,min = 1, max = 16, step = NA,width = NULL),
                    numericInput(inputId='p38_11', label='10. Edad de su padre', value = 65,min = 39, max = 97, step = NA,width = NULL),
                    numericInput(inputId='p38m_11', label='11. Edad de su madre', value = 65,min = 39, max = 97, step = NA,width = NULL),
                    numericInput(inputId='p43', label='12. Ultimo nivel educativo alcanzado del padre', value = 3,min = 1, max = 12, step = NA,width = NULL),
                    numericInput(inputId='p43m', label='13. Ultimo nivel educativo alcanzado de la madre', value = 3,min = 1, max = 12, step = NA,width = NULL),
                    numericInput(inputId='p60', label='14. Cantidad de herman@s', value = 3,min = 1, max = 17, step = NA,width = NULL),
                    numericInput(inputId='p61', label='15. Orden de nacimiento entre su familia', value = 2,min = 1, max = 14, step = NA,width = NULL),
                    numericInput(inputId='p64', label='16. Edad en la que dejó de estudiar', value = 23,min = 6, max = 49, step = NA,width = NULL),
                    numericInput(inputId='p86', label='17. Horas de trabajo a la semana', value = 72,min = 1, max = 150, step = NA,width = NULL),
                    numericInput(inputId='p87', label='18. Años de experiencia en su campo', value = 8,min = 0, max = 57, step = NA,width = NULL),
                    numericInput(inputId='p98', label='19. Edad en la que tuvo su primer empleo', value = 23 ,min = 6, max = 54, step = NA,width = NULL),
                    numericInput(inputId='p122', label='20. Cuartos en el hogar(contando la cocina) en la actualidad', value = 3,min = 1, max = 10, step = NA,width = NULL),
                    numericInput(inputId='p131', label='21. Cantidad de automóbiles propios', value = 0,min = 0, max = 7, step = NA,width = NULL),
                    numericInput(inputId='p132', label='22. Cantidad de miembros que aportan ingreso al hogar', value = 2,min = 0, max = 7, step = NA,width = NULL),
                    numericInput(inputId='p142', label='23. Edad en la que comenzó a vivir en pareja por primera vez', value = 25,min = 14, max = 50, step = NA,width = NULL),
                    numericInput(inputId='p143', label='24. Número de hijos', value = 2,min = 0, max = 8, step = NA,width = NULL),
                    numericInput(inputId='p144', label='25. Edad cuando nació el primer hijo', value = 25 ,min = 13, max = 49, step = NA,width = NULL),
                    numericInput(inputId='p151', label='26. Color de la cara (del mas oscuro al más claro)', value = 6,min = 1, max = 11, step = NA,width = NULL),
                    numericInput(inputId='region', label='27. Region donde habita', value = 2,min = 1, max = 5, step = NA,width = NULL),
                    numericInput(inputId='escolaridadh', label='28. Años de escolaridad', value = 10 ,min = 0, max = 22, step = NA,width = NULL),
                    numericInput(inputId='indigena', label='29. Habla algúna lengua indígena', value = 1 ,min = 0, max = 1, step = NA,width = NULL)
                    
                    
                     
                  ),
                  mainPanel(textOutput("Pred")))
)

server = function (input,output) {
    data <- reactive({
      
        data.frame(escolaridadh=input$escolaridadh,
                   p05=input$p05,
                   p06=input$p06,
                   p09_1=input$p09_1,
                   p10_1=input$p10_1,
                   estatura=input$estatura,
                   p21=input$p21,
                   p23=input$p23,
                   p24=input$p24,
                   p28=input$p28,
                   p38_11=input$p38_11,
                   p38m_11=input$p38m_11,
                   p43=input$p43,
                   p43m=input$p43m,
                   p60=input$p60,
                   p61=input$p61,
                   p64=input$p64,
                   p86=input$p86,
                   p87=input$p87,
                   p98=input$p98,
                   p122=input$p122,
                   p131=input$p131,
                   p132=input$p132,
                   p142=input$p142,
                   p143=input$p143,
                   p144=input$p144,
                   p151=input$p151,
                   region=input$region,
                   escolaridadh=input$escolaridadh,
                   indigena=input$indigena)
    })
    
    pred <- reactive({
        predict(model,data())
    })
    
    output$Pred <- renderPrint(   pred()    )
}


shinyApp(ui=ui,server=server)

#
# rickPredict - a Word Prediction app
#
# Developed by Patrick Simon, August 2019
# for the Capstone project of the JHU Data Science Specialization
#

library(shiny)
library(data.table)
library(stringr)

dt1s<- readRDS("www/dt1s.RData")
dt2s<- readRDS("www/dt2s.RData")
dt3s<- readRDS("www/dt3s.RData")
dt4s<- readRDS("www/dt4s.RData")
dt5s<- readRDS("www/dt5s.RData")

shinyServer(function(input, output) {

    displayText <- reactiveVal(NULL)
    
    output$p1 <- renderText({
        displayText()[1]
    })
    
    output$p2 <- renderText({
        displayText()[2]
    })
    
    output$p3 <- renderText({
        displayText()[3]
    })
    
    output$size <- renderText({
        ## this is a crazy subsetting construct, but it works
        validate(
            need(str_sub(input$tin, -1, -1)==" ",
                 rbind(na.omit(
                     nextWord(word(input$tin,1,-2))$end[
                         grep(paste("^",word(tolower(input$tin),-1,-1),sep=""),
                              nextWord(word(input$tin,1,-2))$end
                              )[1]
                         ]
                     ),
                     dt1s$end[
                         grep(paste("^",word(tolower(input$tin),-1,-1),sep=""),
                              dt1s$end
                              )[1]
                         ]
                 )[1]
            )
        )
        
        pw <- predWrap(input$tin,0.4,count=3)
        print(pw)
        displayText(pw)
        ""
    })
    
    predWrap <- function(...,count=3){
        unique(setorder(nextWord(...),-score,na.last = T)$end)[1:count]
    }
    
    nextWord <- function(phrase,alpha=0.4,count=3){
        loc <- "ISO8859-1" #localeToCharset()
        phrase <- strsplit(tolower(gsub("[[:punct:-[']]]|[0-9]+","", iconv(phrase, from = loc, to = 'ASCII//TRANSLIT'))),"[ ]+")
        phrase <- word(paste(NA,NA,NA,NA,paste((phrase)[[1]],collapse=" ")),-4,-1)
        
        w5 <- dt5s[start==phrase,]
        
        w4 <- dt4s[start==word(phrase,2,-1)]
        w4$score <- w4$score * alpha
        
        w3 <- dt3s[start==word(phrase,3,-1)]
        w3$score <- w3$score * alpha^2
        
        w2 <- dt2s[start==word(phrase,4,-1)]
        w2$score <- w2$score * alpha^3
        
        w1 <- dt1s[1:count]
        na.omit(rbind(w5,w4,w3,w2,w1))
    }
    
    
    output$distPlot <- renderPlot({

        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')

    })

})

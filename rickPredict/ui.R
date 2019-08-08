#
# rickPredict - a Word Prediction app
#
# Developed by Patrick Simon, August 2019
# for the Capstone project of the JHU Data Science Specialization
#

library(shiny)

shinyUI(fluidPage(theme = "bootstrap.css",
    
    titlePanel("rickPredict"),
        tabsetPanel(
               tabPanel("What does it do?",
                        fluidRow(column(9,
                        br(),
                        p("rickPredict is a text prediction tool."),
                        p("Based on an input text, it tries to guess what word
                          is most likely to come up next. It will also show you ", 
                          "the most likely word you are currently typing. You've probably 
                          seen something like this on your phone."),
                        p("Why don't you give it a try? Let rickPredict do its trick!"),
                        br()))),
               tabPanel("How does it work?",
                        fluidRow(column(9,
                        br(),
                        p("How much time do you have?"),
                        p("rickPredict uses an N-gram model with N <= 5 in order to make its predictions."," ",
                          a(href="https://en.wikipedia.org/wiki/N-gram#n-gram_models","[Link #1]"),br(),
                          "In practice, this means that it will use up to four words to predict the next one.",
                          "Possible words are compared using a score calculated with a simple backoff algorithm.",
                          a(href="https://en.wikipedia.org/wiki/Katz%27s_back-off_model","[Link #2]")),
                        p("The underlying N-gram tables were calculated from a sample (ca. 20%) of the English-language subset", 
                        "of the HC Corpora, using a range of natural language processing methods in R.",
                        a(href="http://corpora.epizy.com/about.html","[Link #3]")),
                        p("In order to speed up performance and reduce memory usage, all N-grams with a frequency of 3 or less", 
                          "were not included in the tables. All possible scores for the backoff model were pre-computed."),
                        br()))),
               tabPanel("Who made this?",
                        fluidRow(column(9,
                        br(),
                        p("This was made by Patrick Simon for the capstone project of the ten-course Data Science Specialization",
                          "offered by Johns Hopkins University."),
                        p("Patrick has a background in physics, occasionally co-hosts a German language movie podcast,",
                          a(href="https://rydeorwrong.podcaster.de","[Link]"),
                          ", and is obviously way too fond of things that vaguely qualify as puns."),
                        a(href="https://github.com/psim3141","[Patrick on GitHub]"),
                        br()))), 
                        hr(),br(), type="tabs"
    ),
    fluidRow(
        #sidebarPanel(
        #    h3("Current word:"),
        #    textOutput("size")
        #),
        #
        # Show a plot of the generated distribution
        column(8,offset=2,
            
            h4("Top 3 rickPredicts"),br(),
            splitLayout(
                style = "width: 350px; background-color:#f0f0f0; color:black",
                cellWidths = c(100,5,100,5,100),
                cellArgs = list(style = "padding: 6px"),
                strong(textOutput("p1"),align="center"),
                p("|",align="center"),
                strong(textOutput("p2"),align="center"),
                p("|",align="center"),
                strong(textOutput("p3"),align="center")
            ),
            textInput("tin","",width = 350,placeholder = "Type your text here"),
            #plotOutput("distPlot"),
            
            br(),h4("[Press SPACE to update]"),br(),
            br(),h5("Bonus:"),
            h6("You're probably currently typing... "),br(),
            splitLayout(
                style = "width: 350px; background-color:#f0f0f0",
                cellWidths = 350,
                cellArgs = list(style = "padding: 6px"),
                textOutput("size"))
            )
        )        ,br(),hr(),
    p("Copyright 2019, Patrick Simon. CSS theme courtesy of ",
      a(href="https://bootstrap.build","Bootstrap.Build"),"")
    )
)

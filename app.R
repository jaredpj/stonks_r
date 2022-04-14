#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyWidgets)
library(tidyverse)

# Default job message
msg<-'No job running.'

# Read in data frame
load('~/Documents/GitHub Repos/stonks_r/stonks.rdata')

# Light data cleaning
df$metric<-str_to_title(df$metric)
df$date<-as.Date(df$timestamp)

# Basic application UI
ui <- fluidPage(
  
  # Application title
  titlePanel("Intraday Stock Trends"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      pickerInput('tickers'
                  , label = 'Select Tickers:'
                  , choices = unique(df$ticker)
                  , selected = 'DIS'
                  , multiple = T
      )
      , pickerInput('date'
                    , label = 'Select Date:'
                    , choices = unique(as.character(df$date))
                    , selected = max(df$date)
                    , multiple = F
      )
      , pickerInput('metric'
                    , label = 'Select Metrics:'
                    , choices = c('Open', 'High', 'Low', 'Close')
                    , selected = c('High', 'Low')
                    , multiple = T
      )
      , checkboxInput('show_vol'
                      , label = 'Show volumes?'
                      , value = T
      )
      , actionButton('refresh_data'
                     , "Refresh Data"
                     #, size = 'sm'
      )
    )
    
    # Show a plot of the generated distribution
    , mainPanel(plotOutput('price_plot')
                , plotOutput('vol_plot')
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  observeEvent(input$refresh_data,{
    message('Running ETL.')
    source('stonks_etl.R')
  })
  
  output$price_plot<-renderPlot({
    ggplot(data = df[which(df$ticker %in% input$tickers
                           & as.character(df$date) %in% input$date
                           & df$metric %in% input$metric),]
           , aes(x = timestamp
                 , y = value
                 , group = metric
           )
    )+
      geom_line(aes(color = metric), alpha = .8)+
      facet_wrap(~ticker, scales = 'free')+
      labs(y = 'Price (USD)'
           , x = 'Time'
           , title = 'Intraday Stock Trading'
           , subtitle = 'Prices by the minute'
      )+
      theme_bw()+
      theme(legend.title = element_blank()
            , panel.background = element_blank()
      )
  })
  
  output$vol_plot<-renderPlot({
    
    if(input$show_vol==T){
      ggplot(data = df[which(df$ticker %in% input$tickers
                             & as.character(df$date) %in% input$date
                             & df$metric %in% c('Volume')),]
             , aes(x = timestamp
                   , y = value
             )
      )+
        geom_line(alpha = .5)+
        facet_wrap(~ticker, scales = 'free')+
        labs(y = 'Trade Volume'
             , x = 'Time'
             , subtitle = 'Trade volumes by the minute'
        )+
        theme_bw()+
        theme(panel.background = element_blank())
    }
    
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)

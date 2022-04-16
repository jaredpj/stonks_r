#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Clear the environment
rm(list = ls())
gc()

# Call libs
library(shiny)
library(shinyWidgets)
library(tidyverse)
library(plotly)
library(forecast)

### ---------------------------------- ###
### READ IN TXT FILE WITH YOUR API KEY ###
### ---------------------------------- ###
key<-read_file('av_api_key.txt')
### ---------------------------------- ###

# Get Data from API
source('etl/stonks_etl.R')
source('etl/stock_forecaster.R')

load('data/stonks.rdata')
load('data/forecasts.rdata')

# Read log_file
log_file<-read_file('log_file.txt')

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
      # , actionButton('refresh_data'
      #                , "Refresh Data"
      # )
    )
    
    # Show a plot of the generated distribution
    , mainPanel(
        tabsetPanel(type = "tab"
                    , tabPanel("Time Series"
                               , plotlyOutput('price_plot', width = 830)
                               , plotlyOutput('vol_plot', width = 750)
                               )
                    , tabPanel("1hr Forecast"
                               , plotlyOutput('forecast')
                               )
                    , tabPanel("Raw Data"
                               , dataTableOutput('df_table')
                               )
                    )
              )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  # Automated data refresh (~10min):
  # - Data pull from Alpha Vantage (~2min)
  # - Run forecasting for each ticker (~8min)
  # Trying to time in off hours.
  data_refresh<-reactivePoll(intervalMillis = 86400000
                            , session
                            , valueFunc = function() {
                                get_av_data(api_key = key
                                            , save_file = T
                                            , file_path = 'data/stonks.rdata'
                                )
                                fc<-run_forecast(df, df$ticker)
                                save(fc, file = 'data/forecasts.rdata')
                              
                              }
                            , checkFunc = function() {
                              if (file.exists(log_file))
                                file.info(log_file)$mtime[1]
                              else
                                ""
                            })
  
  # Render the data frame so we can inspect it.
  output$df_table<-renderDataTable({df})
  
  # Plot price(s) over time
  output$price_plot<-renderPlotly({
      price<-ggplot(data = df[which(df$ticker %in% input$tickers
                           & as.character(df$date) %in% input$date
                           & df$metric %in% input$metric),]
           , aes(x = timestamp
                 , y = value
                 , group = metric
                 , text = value
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
            , text = element_text(size = 10)
            , 
            )
    ggplotly(price, tooltip = 'text')
    
  })
  
  # Plot volume of trades over time
  output$vol_plot<-renderPlotly({
    if(input$show_vol==T){
      vol<-ggplot(data = df[which(df$ticker %in% input$tickers
                             & as.character(df$date) %in% input$date
                             & df$metric %in% c('Volume')),]
             , aes(x = timestamp
                   , y = value
                   , text = value
                   )
             )+
        geom_line(alpha = .5)+
        facet_wrap(~ticker, scales = 'free')+
        labs(y = 'Trade Volume'
             , x = 'Time'
             , subtitle = 'Trade volumes by the minute'
        )+
        theme_bw()+
        theme(panel.background = element_blank()
              , text=element_text(size = 10))
      ggplotly(vol, tooltip = 'text')
    }
    
  })
  
  # Plot forecast for first 60 minutes of the next day.
  # Designed to do one at a time, so added a little error trap.
  output$forecast<-renderPlotly({
    
    if(length(input$tickers)>1){
      text = "Please select a single ticker to plot forecast."
      msg <- ggplotly(
        ggplot() + 
        annotate("text", x = 4, y = 25, size=8, label = text) + 
        theme_void()
        )
      msg
    }
    
    if(length(input$tickers)==1){
      ggplotly(forecasts[[input$tickers]])
    }
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)

### ------------- ###
### Dev Scripting ###
### ------------- ###

# Clear workspace
rm(list=ls())
gc()

# Call libraries
library(tidyverse)
library(reshape2)

# Get data
load('~/Documents/GitHub Repos/stonks_r/stonks.rdata')

# Melt: user to select open, close, high, low, volume for plotting
df<-melt(df
         , id.vars = c('ticker', 'timestamp')
         , variable.name = 'metric'
         , value.name = 'value'
         )

# Parameters/Variables
dates<-unique(as.Date(df_melted$timestamp))
metrics<-unique(df_melted$metric)
tickers<-unique(df_melted$ticker)

selected_tickers<-c('DIS', 'MRNA')
selected_dates<-c('2022-03-30')
selected_metrics<-c('high', 'low')

tmp<-df_melted[which((df_melted$ticker %in% selected_tickers)
                     & (as.Date(df_melted$timestamp) %in% as.Date(selected_dates))
                     & (df_melted$metric %in% selected_metrics)
                     ),]

price_plot<-
  ggplot(data = tmp
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

vol_plot<-
  ggplot(data = df_melted[which(df_melted$ticker %in% selected_tickers 
                                & as.Date(df_melted$timestamp) %in% as.Date(selected_dates)
                                & df_melted$metric=='volume'),]
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
  theme(legend.title = element_blank()
        , panel.background = element_blank()
        )

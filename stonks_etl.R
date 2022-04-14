# Dependencies:
# install.packages('alphavantager', 'tidyverse', 'reshape2')

# Call libraries
library(tidyverse)
library(reshape2)
library(alphavantager)

# Define tickers
tickers<-c('DIS', 'MSFT', 'WFC', 'V', 'AAPL'
           , 'SQ', 'XLY', 'XLK', 'INTC', 'MRNA'
)

# API Key
av_api_key('JFWC5K8EAVN6SWO6')

# 
df<-av_get(symbol = "MSFT"
           , av_fun = "TIME_SERIES_INTRADAY"
           , interval = "1min"
           , outputsize = "full"
)

for i in 
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

# Declare data frame list
df_list<-list()

# Loop through tickers (could also write custom function and do `apply()`)
for (i in 1:length(tickers)){
  
  # Get data for ticker i
  df<-av_get(symbol = tickers[i]
             , av_fun = "TIME_SERIES_INTRADAY"
             , interval = "1min"
             , outputsize = "full"
             )
  
  # Add ticker symbol as an index column
  df$ticker<-c(tickers[i])
  
  # Put data frame into list element
  df_list[[i]]<-df
  
  # Take a 30 second break so the API doesn't complain about too many hits
  Sys.sleep(30)

  remove(df) # we won't need this df anymore
  gc() # go ahead and do a garbage clean up to clear the RAM

}

# Bind data frame list into single data frame
df<-bind_rows(df_list)

# Export to .rdata (more memory efficient for production)
save(df, file = 'stonks.rdata')


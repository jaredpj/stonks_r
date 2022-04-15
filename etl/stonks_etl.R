# Dependencies:
# install.packages('alphavantager', 'tidyverse', 'reshape2')

# Call libraries
library(tidyverse)
library(alphavantager)
library(reshape2)

get_av_data<-function(
  tickers = c('DIS', 'MSFT', 'WFC', 'V', 'AAPL', 'SQ', 'XLY', 'XLK', 'INTC', 'MRNA')
  , api_key = ''
  , save_file = F
  , filepath = paste(Sys.Date(), '_av_data.rdata', sep = '')
  ){


  # API Key
  av_api_key(api_key)
  
  # Declare data frame list
  df_list<-list()
  
  # Loop through tickers (could also write custom function and do `apply()`)
  for (i in 1:length(tickers)){
    
    # Get data for ticker i
    df<-av_get(symbol = tickers[i], av_fun = "TIME_SERIES_INTRADAY", interval = "1min", outputsize = "full")
  
    # Add ticker symbol as an index column
    df$ticker<-c(tickers[i])
  
    # Put data frame into list element
    df_list[[i]]<-df
  
    if(i==5){
      Sys.sleep(60)
    }
    
    remove(df) # we won't need this df anymore
    gc() # go ahead and do a garbage clean up to clear the RAM
  
  }
  
  # Bind data frame list into single data frame
  # Melt: user to select open, close, high, low, volume for plotting
  df<-melt(bind_rows(df_list), id.vars = c('ticker', 'timestamp'), variable.name = 'metric', value.name = 'value')
  
  df$date<-as.Date(df$timestamp)
  df$metric<-str_to_title(df$metric)
  
  # Export to .rdata (more memory efficient for production)
  if(save_file==T){
    save(df, file = filepath)
  }
  
  return(df)
}

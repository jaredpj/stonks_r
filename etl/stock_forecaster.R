library(forecast)
library(tidyverse)

# Run forecasting on each ticker.
# Use all of the previous data available to generate ARIMA parameters.
# Let Auto-ARIMA do the heavy lifting. We can run validation metrics later.
# Predict next 60 minutes from latest data points.
# NOTE: This will be run on the schedule with the data refresh as it takes a
# good bit of time to run.

stock_forecaster<-function(data = df, ticker = input$tickers){
  # Filter data: we're going to predict the closing price on the minute for
  # each ticker.
  tmp<-df[which(df$ticker==ticker
                & df$metric=='Close'),]
  
  # Get the y values to predict
  y<-ts(tmp$value, frequency = length(unique(tmp$date))/2)
  # Run Auto-ARIMA model
  fit<-auto.arima(y, D=1, seasonal = T)
  # Run forecast for next 60 minutes
  forecasted<-forecast(fit, h=60)
  
  # We need to get the length of the minutes available for the day for 
  # each ticker.
  day_length<-length(tmp[which(tmp$date==max(tmp$date)),]$value)
  
  # Create a df for plotting things.
  plot_df<-data.frame(Price = c(tmp[which(tmp$date==max(tmp$date)),]$value, tail(forecasted$fitted, 60))
                      , Data_Type = c(rep('Real Price', day_length), rep('Prediction', 60))
                      , color = c(rep('#606060', day_length), rep('#DB4558', 60))
                      , Minute = 1:(day_length+60)
                      )
  
  # Plot those things.
  forecast_plot<-qplot(data = plot_df
                       , x = Minute
                       , y = Price
                       , aes(color = Data_Type)
                       , geom = 'line'
                       )+
    labs(x = "Minutes"
         , y = 'Price'
         , title = 'One Hour Forecast'
         )+
    theme_bw()+
    theme(legend.title = element_blank())
  
  # Return the plot to the user
  return(forecast_plot)
}

# Actually run the forecast and create plots for each ding dang ticker, feller.
run_forecast<-function(data, ticker_col){
  tickers<-unique(ticker_col) # Get each unique ticker
  
  plot_list<-list() # Empty list to fill up later
  
  # Run the forecast on each ticker, and each plot to the list.
  # BONUS: each ggplot figure includes the underlying data. Cha-ching!
  for (i in 1:length(tickers)){
    plot_list[[i]]<-stock_forecaster(data, tickers[i])
  }
  
  # Prolly ought to name each plot so we know what's what later.
  names(plot_list)<-tickers
  
  # Give that ol' list back to the user.
  return(plot_list)
}

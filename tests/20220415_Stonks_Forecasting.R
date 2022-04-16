library(tidyverse)
library(forecast)

tmp<-df[which(df$ticker %in% c('DIS')
              & df$metric=='Close'),]

y<-ts(tmp$value, frequency = length(unique(tmp$date))/2)
fit<-auto.arima(y, D=1, seasonal = T)
forecasted<-forecast(fit, h=60)

autoplot(forecasted)

day_length<-length(tmp[which(tmp$date==max(tmp$date)),]$value)

plot_df<-data.frame(Price = c(tmp[which(tmp$date==max(tmp$date)),]$value, tail(forecasted$fitted, 60))
                    , Data_Type = c(rep('Real Price', day_length), rep('Prediction', 60))
                    , color = c(rep('#606060', day_length), rep('#DB4558', 60))
                    , Minute = 1:(day_length+60)
                    )

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
               theme(legend.title = element_blank()
                     )

forecast_plot<-ggplotly(forecast_plot)



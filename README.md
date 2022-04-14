# stonks_r
R Shiny version of the intraday trading trends for select tickers from Alpha Vantage.

## Purpose
A friend of mine (Kamadi) requested some simple data visualizations of intraday time series of ten different stocks, so that he could observe general patterns of trading (volumes and increases/decreases in prices) without any real modeling or forecasting behind the scenes. This report was initially created using Streamlit in Python and is hosted on Heroku: https://kamadistonks.herokuapp.com. 

For the purposes of demonstrating my ability to generate reporting in R Shiny, I have recreated it here along with a few extra features:
1. The ability to select different metrics to show in the time series plots.
2. Whether to show trade volumes in addition to prices.
3. A user option to refresh the data (still working on a progress bar here; takes about 5 minutes or so to run).

## Directory Structure
In order to keep it simple, I decided to forgo a directory structure. I would not advise this for a production application, but for the sake of expediency here, I've opted to keep it flat.

## Dependencies
- tidyverse
- reshape2
- alphavantager
- shiny
- shinyWidgets
- shinycssloaders
- forecast

# Setup
This app was developed on R v4.1.2. Run setup.R to install dependencies.

# Files
`stonks_etl.R` is an ETL script that pulls all available intraday data (previous two weeks) for ten stocks at the minute level from the Alpha-Vantage API. There is a built in 30 second delay because you are only allowed to make a certain amount of API calls in a given time span. The script takes approximately five minutes to run. This script outputs `stonks.rdata`.

`app.R` is the Shiny application file.

`stonks.rdata` contains intraday price and volume data in a minute-level time series of ten stocks. Data acquired from Alpha-Vantage API.

`20220414_Stonks_Dev.R` is development code for the application.



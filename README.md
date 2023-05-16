# House Prices Analysis Shiny App

This is a Shiny web application developed to explore patterns and valuable information on land and house prices in Canada and other countries.

## Description

The application has four main tabs:

- **Introduction:** Gives a general overview of what the app is for, and displays a data table.
- **Map:** Displays a dynamic map and bar chart of house prices in Canada by province.
- **Trend:** Allows users to view changes in a specific index and compare it across different provinces.
- **Prediction:** Provides predictions for a specific index for the next five years, based on user's input.

## Installation and Usage

To install and run this Shiny app:

1. Clone this repository.
2. Open RStudio.
3. Set your working directory to the location of the cloned repository.
4. Install the required R packages using the following commands in R console:

```r
install.packages(c('tidyverse', 'lubridate', 'DT', 'shiny', 'leaflet', 'plotly', 'forecast', 'shinythemes'))

## Description

The application has four main tabs:

1. **Introduction:** Gives a general overview of what the app is for, and displays a data table.

2. **Map:** Displays a dynamic map and bar chart of house prices in Canada by province.

3. **Trend:** Allows users to view changes in a specific index and compare it across different provinces.

4. **Prediction:** Shows forecasted housing prices for a selected province and index type.

## Data

The dataset is available at [https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1810020501](https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1810020501). It displays the monthly NHPI for new housing in Canada starting from January 1981.



## Installation

The required packages for this app can be installed in R using the following commands:

```R
if (!require(tidyverse)) install.packages('tidyverse')
if (!require(lubridate)) install.packages('lubridate')
if (!require(DT)) install.packages('DT')
if (!require(shiny)) install.packages('shiny')
if (!require(leaflet)) install.packages('leaflet')
if (!require(plotly)) install.packages('plotly')
if (!require(forecast)) install.packages('forecast')
if (!require(shinythemes)) install.packages('shinythemes')


## Author
- Name: Kamal Akbari
- Email: kamalakbari77@gmail.com
- LinkedIn: https://www.linkedin.com/in/kamalakbari/
- Website: www.kakbari.com

## License

This project is licensed under the MIT License.

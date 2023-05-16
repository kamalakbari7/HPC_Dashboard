###  Name: Kamal Akbari  ###################################
###  Email: kamalakbari77@gmail.com  #######################
###  LinkedIn: https://www.linkedin.com/in/kamalakbari/  ###
###  Website: www.kakbari.com ##############################
###  License: MIT ##########################################



#Install required packages------------------------------------------------------

if (!require(tidyverse)) install.packages('tidyverse')
if (!require(lubridate)) install.packages('lubridate')
if (!require(DT)) install.packages('DT')
if (!require(shiny)) install.packages('shiny')
if (!require(leaflet)) install.packages('leaflet')
if (!require(plotly)) install.packages('plotly')
if (!require(forecast)) install.packages('forecast')
if (!require(shinythemes)) install.packages('shinythemes')

#Importing the required packages------------------------------------------------
library(forecast)
library(shinythemes)
library(tidyverse)
library(lubridate)
library(DT)
library(shiny)
library(geojsonio)
library(leaflet)
library(plotly)
getwd()
# Reading data and clean the data-----------------------------------------------
data <- read.csv("data/provinces.csv")
summary(data)
class(data$REF_DATE)
head(data)
data$date <- ymd(data$REF_DATE)
# any(is.na(data))
# any(is.na(data$ValueIndex))
# is.null(data)
# 
# class(data$date)
# unique(data$Provinces)
# max(data$date)

# Reading the spatial data------------------------------------------------------
world_map <-geojson_read("data/canada.geojson", what = "sp")
library(sp)
par(mar=c(0,0,0,0))
plot(world_map, col="grey")
colnames(world_map)

# define the ui for the app-----------------------------------------------------
ui <- navbarPage(theme = shinytheme("yeti"),"House Prices Analysis",
                 tags$head(
                   tags$style(".recalculating { opacity: inherit !important; }")
                 ),
  tabPanel("Introduction",
           h3("What is this for?"),
           p('This dashboard explores patterns and valuable information on land and house prices in Canada and other countries.' ),
           hr(),
           h3("Data"),
           p("The dataset available at https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1810020501 
             displays the monthly NHPI for new housing in Canada starting from January 1981."),
           tags$image(src="https://upload.wikimedia.org/wikipedia/commons/d/d7/Canada_topo.jpg", width="25%"),
           h3("Data View"),
           #hr(),
           DTOutput("table"),
           hr(),
           h2("Contact Information"),
           p("Name: Kamal Akbari"),
           p("Email: kamalakbari77@gmail.com"),
           p("LinkedIn: https://www.linkedin.com/in/kamalakbari/"),
           p("Website: www.kakbari.com"),
           p("License: MIT"),
           hr()
  ),
  tabPanel("Map",
    sidebarLayout(
      sidebarPanel(
        selectInput("TypeIndexMap", "Index Type", choices = unique(data$TypeIndex)),
        selectInput("date", 
                    "Date", 
                    choices = rev(sort(unique(format(data$date, "%Y-%m-%d")))),
                    selected = max(format(data$date, "%Y-%m-%d"))),
        
        # # Create a select input with only the dates for which there is data
        h4("Index By Province"),
        plotlyOutput("bar"),
        hr(),
        p("The chart displays the ranking of each province based on the chosen index, 
          while the map provides the corresponding values for each province")
      ),
      mainPanel(
        leafletOutput("map", height = 800)
      )
    )
  ),
  tabPanel("Trend",
           sidebarLayout(
             sidebarPanel(
               selectInput("TypeIndexTrend", "Index Type", choices = unique(data$TypeIndex)),
               selectInput("Provinces", "Province", choices = unique(data$Provinces), 
                           selected = "Ontario", multiple = T),
               hr(),
               p("To view changes in a specific index and compare it across different provinces, 
               simply choose the Index Type and input the desired provinces in the search bar. 
                 The resulting graphs on the right will display the information you need.")
             ),
             mainPanel(
               plotlyOutput("line"),
               plotlyOutput("heatmap")
             )
           )
  ),
  tabPanel("Prediction",
           sidebarLayout(
             sidebarPanel(
               selectInput("province", "Province", choices = unique(data$Provinces)),
               selectInput("type_index", "Index Type", choices = unique(data$TypeIndex)),
               hr(),
               p("To view predictions for a specific index for five future years, 
                 simply choose the Index Type and input the desired provinces in 
                 the search bar. The resulting graphs on the right will display 
                 the predicted information in red colour.")
             ),
             mainPanel(
               plotlyOutput("predict")
             )
           )
  )
)

#Define the server logic--------------------------------------------------------
server <- function(input, output) {
  output$table <- renderDataTable({
    data[, c(1,2,4,11)]
  })
  
  
  # Draw a bar chart------------------------------------------------------------
  output$bar <- renderPlotly({
    req(input$TypeIndexMap)
    df <- data %>% filter(date == as.Date(input$date) & TypeIndex == input$TypeIndexMap) %>%
      select(Provinces, ValueIndex) %>%
      filter(Provinces != "") %>%
      group_by(Provinces) %>%
      summarise(ValueIndex = sum(ValueIndex, na.rm = T)) %>%
      ggplot(aes(x = reorder(Provinces, ValueIndex), y = ValueIndex)) +
      geom_col(fill = "lightblue") +
      coord_flip() +
      labs(x = "Provinces", y = "ValueIndex", title = "")
  })
  
  # Draw a map------------------------------------------------------------------
  observe({
    req(input$TypeIndexMap)
    df <- data %>% filter(date==as.Date(input$date) & TypeIndex == input$TypeIndexMap)%>% select(Provinces, ValueIndex)
    world_map@data <- world_map@data %>% left_join(df, by=c("name"="Provinces")) 
    world_map@data[is.na(world_map@data)] <- 0 # fill na with 0
    colorPal <- colorNumeric(palette = "viridis", world_map@data$ValueIndex)
    # "viridis", as_cmap=True
    output$map <- renderLeaflet({
      world_map %>%
        leaflet() %>% addTiles() %>% addPolygons(
          stroke = T,
          weight = 4,  # Adjust this value for line thickness
          color = ~colorPal(ValueIndex),
          smoothFactor = 0.5,
          fillOpacity = 0.7,
          label=~paste0(name, "'s index is ", ValueIndex)
        ) %>%
        addLegend(  
          pal = colorPal, 
          values = world_map@data$ValueIndex, 
          position = "bottomright",
          title = paste("Index"),
          bins = 6
        )
    })
  })
  
  # Draw a line chart-----------------------------------------------------------
  output$line <- renderPlotly({
    req(input$TypeIndexTrend)
    data %>% filter(Provinces %in% input$Provinces & TypeIndex == input$TypeIndexTrend)%>% 
      ggplot(aes(x=date, y=ValueIndex, color=Provinces)) + geom_line() +
      labs(x="Date", y="Value of Index", title="Changes in Index by Time")
  })
  
  # Draw a heatmap--------------------------------------------------------------
  output$heatmap <- renderPlotly({
    req(input$TypeIndexTrend)
    data %>% filter(Provinces %in% input$Provinces & TypeIndex == input$TypeIndexTrend) %>% 
      ggplot(aes(x=date, y=Provinces, fill=ValueIndex)) + geom_tile() +
      scale_fill_gradientn(colors = c("blue", "red"))  + 
      labs(x="Date", y="Provinces", title="Heatmap of the Index by Time")
  })
  
  
#Prediction---------------------------------------------------------------------
  output$predict <- renderPlotly({
    # Subset the data for the selected province and index type
    province_data <- data %>% 
      filter(Provinces == input$province, TypeIndex == input$type_index) %>% 
      arrange(date)
    
    # Convert the 'Value' column to a time series object
    ts_data <- ts(province_data$ValueIndex, start = c(year(min(province_data$date)),
                                                      month(min(province_data$date))), frequency = 12)
    
    # Fit an ARIMA model and forecast the next 5 years (60 months)
    fit <- auto.arima(ts_data)
    future_forecast <- forecast(fit, h = 60)
    
    # Create a data frame from the forecast object for easier manipulation with plotly
    # Create a data frame from the forecast object for easier manipulation with plotly
    forecast_df <- data.frame(
      Date = seq(max(province_data$date), by = "month", length.out = length(future_forecast$mean)+1)[-1],
      Value = as.numeric(future_forecast$mean),
      DataType = "Predicted"
    )
    
    
    # Create a data frame with the original data
    original_df <- data.frame(
      Date = province_data$date,
      Value = province_data$ValueIndex,
      DataType = "Real"
    )
    
    # Combine the two data frames
    combined_df <- rbind(original_df, forecast_df)
    
    # Generate the interactive plot with plotly
    plot_ly(combined_df) %>%
      add_lines(x = ~Date, y = ~Value, color = ~DataType, colors = c("Real" = "black", "Predicted" = "red")) %>%
      layout(title = paste("5-year forecast for", input$province, "and index type", input$type_index),
             xaxis = list(title = "Year"),
             yaxis = list(title = "Value"))
  })
  
}

#-------------------------------------------------------------------------------
shinyApp(ui = ui, server = server)



ui <- fluidPage(
    titlePanel("Global Soil Regulation Dashboard"),
    
    sidebarLayout(
        sidebarPanel(
            selectInput("continent", "Select Continent:",
                        choices = c("All" = "All", unique(soil_data$Continent))),
            
            uiOutput("countrySelector"),  # Dynamic country selection based on continent
            uiOutput("regionSelector"),  # Dynamic region selection based on country
            
            checkboxGroupInput("soil_activity", "SoiLEX Categories:",
                               choices = unique(soil_data$SoilLEX.Keyword))
        ),
        
        mainPanel(
            leafletOutput("worldMap", height = 600),
            dataTableOutput("policyTable")
        )
    )
)

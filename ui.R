

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
    ),
    tags$footer(
        tags$hr(),
        HTML("Data sourced from the <a href='https://www.fao.org/soils-portal/soilex/en/' target='_blank'>FAO Soil Portal</a>. Data downloaded on 8/13/2024."),
        br(),
        HTML("Check out the project on <a href='https://github.com/ferrojulio/Legislation-dashboard' target='_blank'>GitHub</a>."),
        br(),
        "Dashboard developed by Julio Pachon."
    )
)

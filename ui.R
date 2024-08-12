# ui.R

ui <- fluidPage(
    titlePanel("Global Soil Regulation Dashboard"),
    
    sidebarLayout(
        sidebarPanel(
            selectInput("category", "Select Category:",
                        choices = unique(soil_data$Category)),
            selectInput("regulation_type", "Select Regulation Type:",
                        choices = c("All", unique(soil_data$Category))) # Example categories, adjust as needed
        ),
        
        mainPanel(
            leafletOutput("worldMap", height = 600),
            dataTableOutput("policyTable")
        )
    )
)



ui <- fluidPage(
    titlePanel("Global Soil Regulation Dashboard"),

   
    

    HTML("<p><strong>Disclaimer:</strong> The data presented reflect only the number of documents analyzed on FAO SoilLEx at August 8, 2024 and should not be used to assess the effectiveness of regional soil governance. Higher document counts do not necessarily indicate superior soil protection or governance.</p>"),
    
    HTML(paste(
        "<p><strong>Citation:</strong> Bourhis, H., Rodriguez Eugenio, N., Poch, R.M., Lefèvre, C., Vargas, R. (2022). SoiLEX, The New Tool of the Global Soil Partnership to Strengthen Soil Governance. In: Ginzky, H., et al. <em>International Yearbook of Soil Law and Policy 2020/2021</em>. International Yearbook of Soil Law and Policy, vol 2020. Springer, Cham. <a href='https://doi.org/10.1007/978-3-030-96347-7_18' target='_blank'>https://doi.org/10.1007/978-3-030-96347-7_18</a></p>"
    )),
    
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

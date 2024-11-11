server <- function(input, output, session) {
    eu_members <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic",
                    "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary",
                    "Ireland", "Italy", "Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands",
                    "Poland", "Portugal", "Romania", "Slovakia", "Slovenia", "Spain", "Sweden")
    
    
    
    
    # Dynamic UI for country selector based on selected continent
    filtered_data <- reactive({
        data <- soil_data
        if (input$continent != "All") {
            data <- data[data$Continent == input$continent, ]
        }
        if (!is.null(input$country) && length(input$country) > 0) {
            data <- data[data$Country %in% input$country, ]
        }
        if (!is.null(input$region) && length(input$region) > 0) {
            data <- data[data$Region %in% input$region, ]
        }
        if (!is.null(input$soil_activity) && length(input$soil_activity) > 0) {
            data <- data[data$`SoilLEX.Keyword` %in% input$soil_activity, ]
        }
        data
    })
    
    # Dynamic UI for country selector based on selected continent
    output$countrySelector <- renderUI({
        if (input$continent == "All") {
            choices <- unique(soil_data$Country)
        } else {
            choices <- unique(soil_data$Country[soil_data$Continent == input$continent])
        }
        choices <- sort(choices)
        selectizeInput("country", "Select Country:", choices = choices, multiple = TRUE, 
                       options = list(maxItems = 3)) # Limit selection to three countries
    })
    
    # Dynamic UI for region selector based on selected countries
    output$regionSelector <- renderUI({
        if (is.null(input$country) || length(input$country) == 0) {
            return(NULL)
        }
        valid_regions = unique(soil_data$Region[soil_data$Country %in% input$country])
        valid_regions <- sort(valid_regions)
        checkboxGroupInput("region", "Select Regions:", choices = valid_regions)
    })
    # Aggregated data for the map
    aggregated_data <- reactive({
        filtered_data() %>%
            group_by(Country) %>%
            summarise(Regulations = n()) %>%
            ungroup()
    })
    
    # Join with world map data
    world_data <- reactive({
        left_join(world, aggregated_data(), by = c("name" = "Country"))
    })
    
    # Color palette for the map
    pal <- reactive({
        data <- world_data()
        if (nrow(data) == 0 || all(is.na(data$Regulations))) {
            return(NULL)
        } else {
            colorNumeric(palette = "YlOrRd", domain = data$Regulations)
        }
    })
    
    # Render the map
    output$worldMap <- renderLeaflet({
        leaflet(world) %>% 
            addTiles() %>%
            setView(lng = 0, lat = 20, zoom = 2)
    })
    
    # Update the map with filtered data
    observe({
        data <- world_data()
        palette <- pal()
        
        leafletProxy("worldMap", data = data) %>%
            clearShapes() %>%
            addPolygons(
                fillColor = ~if (!is.null(palette)) palette(Regulations) else "transparent",
                fillOpacity = 0.7, 
                color = "white", 
                weight = 0.5,
                label = ~paste(name, ": ", Regulations, " Regulations"),
                highlightOptions = highlightOptions(weight = 3, color = "#666", fillOpacity = 0.7)
            )
    })
    
    
    # Render the data table
    output$policyTable <- renderDataTable({
        datatable(filtered_data(), options = list(pageLength = 10), escape = FALSE)
    })
    
    output$soilLexBarChart <- renderPlotly({
        # Determine if countries are selected
        if (is.null(input$country) || length(input$country) == 0) {
            # If no countries are selected, show a bar chart for the entire world data
            soil_lex_count <- soil_data %>%
                count(`SoilLEX.Keyword`, sort = TRUE)
            
            p <- ggplot(soil_lex_count, aes(x = reorder(`SoilLEX.Keyword`, -n), y = n)) +
                geom_bar(stat = "identity", fill = "skyblue") +
                labs(title = "Global SoilLEX Keyword Frequency", x = "SoilLEX Keyword", y = "Frequency") +
                theme_minimal() +
                theme(axis.text.x = element_text(angle = 45, hjust = 1)) # Rotate x-axis labels for readability
            
        } else {
            # If countries are selected, show a comparison for up to three countries
            soil_lex_count <- filtered_data() %>%
                filter(Country %in% input$country) %>% # Filter to selected countries
                count(Country, `SoilLEX.Keyword`, sort = TRUE)
            
            # Create a ggplot bar chart with a separate bar for each country
            p <- ggplot(soil_lex_count, aes(x = reorder(`SoilLEX.Keyword`, -n), y = n, fill = Country)) +
                geom_bar(stat = "identity", position = "dodge") + # Position bars side by side
                labs(title = "SoilLEX Keyword Frequency by Country", x = "SoilLEX Keyword", y = "Frequency") +
                theme_minimal() +
                theme(axis.text.x = element_text(angle = 45, hjust = 1)) # Rotate x-axis labels for readability
        }
        
        # Convert ggplot chart to Plotly for interactivity
        ggplotly(p, tooltip = c("x", "y", "fill"))
    })
}

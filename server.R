server <- function(input, output, session) {
    
    # Reactive expression to filter data based on user input
    filtered_data <- reactive({
        req(input$category) # Ensure input is available
        
        data <- soil_data
        
        # Filter by selected category
        if (input$regulation_type != "All") {
            data <- data %>%
                filter(Category == input$category & Category == input$regulation_type)
        } else {
            data <- data %>%
                filter(Category == input$category)
        }
        
        data
    })
    
    # Aggregated data by country
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
        
        # Check if the data is empty
        if (nrow(data) == 0 || all(is.na(data$Regulations))) {
            return(NULL) # Return NULL if no data is available to avoid errors
        } else {
            colorNumeric(
                palette = "YlOrRd",
                domain = data$Regulations
            )
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
                fillColor = if (!is.null(palette)) ~palette(Regulations) else "transparent", # Handle empty data
                fillOpacity = 0.7, 
                color = "white", 
                weight = 0.5,
                label = ~paste(name, ": ", Regulations, " Regulations"),
                highlightOptions = highlightOptions(weight = 3, color = "#666", fillOpacity = 0.7)
            )
    })
    
    # Render the table
    output$policyTable <- renderDataTable({
        datatable(filtered_data(), 
                  options = list(pageLength = 10),
                  escape = FALSE)
    })
}

# global.R

# Load required libraries
library(shiny)
library(leaflet)
library(DT)
library(dplyr)
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)
library(plotly)


# Load data
soil_data <- read.csv("data/SoilLEXdata modified.csv")

# Load world map using rnaturalearth
world <- ne_countries(scale = "medium", returnclass = "sf")



###look at FAOLEX and ECOLEX 
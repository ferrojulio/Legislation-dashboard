# global.R

# Load required libraries
library(shiny)
library(leaflet)
library(DT)
library(dplyr)
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)

# Load data
soil_data <- read.csv("data/soil_regulations.csv")

# Load world map using rnaturalearth
world <- ne_countries(scale = "medium", returnclass = "sf")

if (!requireNamespace("arrow", quietly = TRUE)) {
  install.packages("arrow")
}
if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}
if (!requireNamespace("sf", quietly = TRUE)) {
  install.packages("sf")
}

library(arrow)
library(dplyr)
library(sf)



# Converting Parquet to RDS
years <- 2015:2020
for (year in years) {
  input_path <- paste0("data-raw/traffic-accidents-", year, ".parquet")
  output_path <- paste0("data/traffic_accidents_", year, ".Rds")

  if (file.exists(input_path)) {
    accidents_sf <- read_parquet(input_path) |>
      st_as_sf(coords = c("longitude", "latitude"), crs = 4326)
    saveRDS(accidents_sf, file = output_path)
    print(paste("Successfully converted:", input_path, "->", output_path))
  } else {
    warning(paste("File not found, skipping:", input_path))
  }
}



# Loading RDS files into variables
for (year in years) {
  file_path <- paste0("data/traffic_accidents_", year, ".Rds")
  variable_name <- paste0("traffic_accidents_", year)

  if (file.exists(file_path)) {
    assign(variable_name, readRDS(file_path))
    print(paste("Loaded:", file_path, "-> created variable:", variable_name))
  } else {
    warning(paste("RDS file not found, skipping:", file_path))
  }
}



# Merging all years into a single analysis data frame
yearly_variable_names <- paste0("traffic_accidents_", years)
list_of_yearly_data <- mget(yearly_variable_names)
accidents_analysis <- dplyr::bind_rows(list_of_yearly_data)
saveRDS(accidents_analysis, file = "data/accidents_analysis.Rds")

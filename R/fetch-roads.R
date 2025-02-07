#' Fetch road data from OpenStreetMap
#'
#' `fetch_roads()` fetches road data from OpenStreetMap. It retrieves roads
#' within a specified bounding box or within an area defined by a center point
#' and a radius. Additionally, roads can be cropped to fit within the specified
#' boundaries.
#'
#' @param x An object defining the area or location of interest. This can be:
#'   - A `matrix` representing a bounding box.
#'   - An `sfc_POINT` object representing a central point.
#'   - Numeric values representing longitude (`x`) and latitude (`y`).
#'   - A character string containing a pre-defined Overpass query.
#' @param y Numeric value representing latitude (required if `x` is numeric
#'   and represents longitude).
#' @param crop A logical value indicating whether to crop road data to the
#'   specified area (default: `FALSE`).
#' @param radius Numeric value representing the search radius in meters
#'   (default: `15`).
#' @param ... Additional arguments passed to the method.
#' @return An `sf` object of class `LINESTRING`, containing road data with
#'   the followings columns:
#'   \describe{
#'     \item{id}{Unique road identifier}
#'     \item{highway}{Road classification (e.g. "residential", "primary")}
#'     \item{name}{Road name}
#'     \item{layer}{Layer information for roads at different elevations}
#'     \item{oneway}{Logical indicating whether the road is one-way}
#'     \item{osm_id}{OpenStreetMap unique identifier}
#'   }
#' @export
#' @examples
#' \dontrun{
#' # Download road data
#' bbox <- create_bbox(
#'   north =  35.17377,
#'   south =  35.16377,
#'   east  = 136.91590,
#'   west  = 136.90090
#' )
#' roads <- fetch_roads(bbox)
#'
#' # Plot the roads
#' plot(roads$geometry)
#' }
fetch_roads <- function(x, ...) {
  UseMethod("fetch_roads")
}

#' @rdname fetch_roads
#' @export
fetch_roads.matrix <- function(x, crop = FALSE, ...) {
  query <- build_query(bbox = x)
  fetch_roads(query, crop = crop, ...)
}

#' @rdname fetch_roads
#' @export
fetch_roads.sfc_POINT <- function(x, radius = 15, crop = FALSE, ...) {
  coord <- sf::st_coordinates(x)
  fetch_roads(x = coord[1], y = coord[2], radius = radius, ...)
}

#' @rdname fetch_roads
#' @export
fetch_roads.numeric <- function(x, y, radius = 15, crop = FALSE, ...) {
  query <- build_query(rad = radius, lon = x, lat = y)
  fetch_roads(query, crop = crop, ...)
}

#' @rdname fetch_roads
#' @export
fetch_roads.character <- function(x, crop = FALSE, ...) {
  # Retrieve road data from OpenStreetMap
  osm_data <- osmdata::osmdata_sf(x)
  road_lines <- purrr::pluck(osm_data, "osm_lines")

  # Return an empty sf object if no roads are found
  if (is.null(road_lines)) {
    cli::cli_alert_info("No roads found for the given condition.")
    return(create_empty_roads_sf())
  }

  # Process road data
  road_lines <- road_lines %>%
    correct_oneway_geometries() %>%
    convert_oneway_to_boolean()

  # Crop road data if required
  if (crop) {
    road_lines <- crop_roads(road_lines, x)
  }

  # Convert MULTILINESTRING to LINESTRING and ensure required columns
  roads <- road_lines %>%
    convert_multilinestring_to_linestring() %>%
    ensure_required_columns()

  return(roads)
}


# Building an Overpass query ----------------------------------------------

# Function to build an Overpass query
build_query <- function(...) {
  query_params <- list(...)

  # Generate bounding box (bbox) and search radius query string
  bbox_str <- generate_bbox(query_params)
  radius_str <- generate_radius(query_params)

  # Define highway types as a regex pattern
  highway_types <- stringr::str_c(pavement::osm_highway_values, collapse = "|")
  highway_regex <- stringr::str_glue("\"highway\"~\"^({highway_types})$\"")

  # Construct Overpass query
  overpass_query <- stringr::str_glue("
  [out:xml][timeout:25];
  (
    node{radius_str} [{highway_regex}]{bbox_str};
    way{radius_str} [{highway_regex}]{bbox_str};
    relation{radius_str} [{highway_regex}]{bbox_str};
  );
  (._;>;);
  out body;
  ")

  # Store query parameters as an attribute
  attr(overpass_query, "query_params") <- query_params

  return(overpass_query)
}

# Generate bbox (bounding box) query string
generate_bbox <- function(params) {
  bbox <- purrr::pluck(params, "bbox")

  # Return an empty string if bbox is not provided
  if (is.null(bbox)) return("")

  stringr::str_glue("({bbox['y', 'min']},{bbox['x', 'min']},{bbox['y', 'max']},{bbox['x', 'max']})")
}

# Generate search radius query string
generate_radius <- function(params) {
  rad <- purrr::pluck(params, "rad")
  lon <- purrr::pluck(params, "lon")
  lat <- purrr::pluck(params, "lat")

  # Return an empty string if any required parameter is missing
  if (any(is.null(c(rad, lon, lat)))) return("")

  stringr::str_glue("(around:{rad},{lat},{lon})")
}


# Processing road data ----------------------------------------------------

# Create an empty roads sf object
create_empty_roads_sf <- function() {
  sf::st_sf(tibble::tibble(
    id       = character(),
    highway  = character(),
    name     = character(),
    layer    = character(),
    oneway   = logical(),
    osm_id   = character(),
    geometry = sf::st_sfc(crs = 4326)
  ))
}

# Reverse geometries for roads marked as one-way in the reverse direction
correct_oneway_geometries <- function(roads) {
  roads %>%
    dplyr::mutate(
      is_reversed = !is.na(.data$oneway) & .data$oneway == -1,
      geometry    = dplyr::if_else(.data$is_reversed,
                                   sf::st_reverse(.data$geometry),
                                   .data$geometry)
    ) %>%
    dplyr::select(!"is_reversed")
}

# Convert `oneway` column to a boolean vector
convert_oneway_to_boolean <- function(roads) {
  roads %>%
    dplyr::mutate(oneway = .data$oneway %in% c("yes", "-1"))
}

# Crop road data based on query parameters
crop_roads <- function(roads, query) {
  params <- attr(query, "query_params")
  crop_area <- determine_crop_area(params)

  roads %>%
    sf::st_set_agr("constant") %>%
    sf::st_crop(crop_area)
}

# Determine the cropping area from query parameters
determine_crop_area <- function(params) {
  bbox <- purrr::pluck(params, "bbox")
  if (!is.null(bbox)) {
    return(convert_bbox_to_polygon(bbox, crs = 4326))
  }

  rad <- purrr::pluck(params, "rad")
  lon <- purrr::pluck(params, "lon")
  lat <- purrr::pluck(params, "lat")

  if (!is.null(rad) && !is.null(lon) && !is.null(lat)) {
    return(sf::st_point(c(lon, lat)) %>%
             sf::st_buffer(rad) %>%
             sf::st_sfc(crs = 4326))
  }

  cli::cli_abort("Either {.code bbox} or {.code rad}, {.code lon}, and {.code lat} must be provided.")
}

# Convert MULTILINESTRING to LINESTRING and generate unique IDs
convert_multilinestring_to_linestring <- function(roads) {
  roads %>%
    sf::st_set_agr("constant") %>%
    sf::st_cast("LINESTRING") %>%
    dplyr::mutate(id = stringr::str_glue("rd_{sprintf('%04x', seq_len(dplyr::n()))}"))
}

# Ensure all required columns exist
ensure_required_columns <- function(roads) {
  required_cols <- c("id", "highway", "name", "layer", "oneway", "osm_id")
  missing_cols <- setdiff(required_cols, colnames(roads))

  roads %>%
    dplyr::mutate(dplyr::across(dplyr::all_of(missing_cols), ~ NA_character_)) %>%
    dplyr::select(dplyr::all_of(required_cols)) %>%
    tibble::remove_rownames()
}

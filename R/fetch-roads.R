#' Fetch road data from OpenStreetMap
#'
#' `fetch_roads()` fetches road data from OpenStreetMap. It retrieves roads
#' within a specified bounding box or within an area defined by a center point
#' and a radius. Additionally, roads can be cropped to fit within the specified
#' boundaries.
#'
#' @param x An object defining the area or location of interest. This can be:
#'   - A `matrix` representing a bounding box.
#'   - An `sfc_POINT` or `POINT` object representing a central point.
#'   - Numeric values representing longitude (`x`) and latitude (`y`).
#'   - A character string containing a pre-defined Overpass query.
#' @param y Numeric value representing latitude (required if `x` is numeric
#'   and represents longitude).
#' @param crop A logical value indicating whether to crop road data to the
#'   specified area (default: `FALSE`).
#' @param circle_crop A logical value indicating whether to crop roads within a
#'   circular area instead of a bounding box (default: `FALSE`). This is only
#'   effective if `crop = TRUE`.
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
#' # Define a bounding box
#' bbox <- create_bbox(north =  35.17377,
#'                     south =  35.16377,
#'                     east  = 136.91590,
#'                     west  = 136.90090)
#'
#' # Download road data with in the bounding box
#' roads <- fetch_roads(bbox)
#'
#' # Plot the roads
#' plot(roads$geometry)
#'
#' # Download and crop road data strictly to the bounding box
#' roads_cropped <- fetch_roads(bbox, crop = TRUE)
#' plot(roads_cropped$geometry)
#'
#' # Download roads using a center point and radius
#' center_lon <- 136.8817
#' center_lat <-  35.1709
#' radius_m   <- 500
#'
#' roads_radius <- fetch_roads(x      = center_lon,
#'                             y      = center_lat,
#'                             radius = radius_m)
#' plot(roads_radius$geometry)
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
fetch_roads.sfc_POINT <- function(x,
                                  radius      = 15,
                                  crop        = FALSE,
                                  circle_crop = FALSE,
                                  ...) {
  fetch_roads.POINT(x, radius, crop, circle_crop, ...)
}

#' @rdname fetch_roads
#' @export
fetch_roads.POINT <- function(x,
                              radius      = 15,
                              crop        = FALSE,
                              circle_crop = FALSE,
                              ...) {
  coord <- sf::st_coordinates(x)
  fetch_roads(x           = coord[1],
              y           = coord[2],
              radius      = radius,
              crop        = crop,
              circle_crop = circle_crop,
              ...)
}

#' @rdname fetch_roads
#' @export
fetch_roads.numeric <- function(x,
                                y,
                                radius      = 15,
                                crop        = FALSE,
                                circle_crop = FALSE,
                                ...) {
  query <- build_query(rad = radius, lon = x, lat = y)
  fetch_roads(query, crop = crop, circle_crop = circle_crop, ...)
}

#' @rdname fetch_roads
#' @export
fetch_roads.character <- function(x, crop = FALSE, circle_crop = FALSE, ...) {
  # Retrieve road data from OpenStreetMap
  osm_data <- osmdata::osmdata_sf(x)
  road_lines <- osm_data[["osm_lines"]]

  # Return an empty sf object if no roads are found
  if (is.null(road_lines)) {
    message("No roads found for the given condition.")
    return(create_empty_roads_sf())
  }

  # Correct oneway geometries and convert to boolean
  if ("oneway" %in% names(road_lines)) {
    road_lines <- correct_oneway_geometries(road_lines)
    road_lines <- convert_oneway_to_boolean(road_lines)
  } else {
    road_lines$oneway <- FALSE
  }

  # Crop road data if required
  if (crop) {
    road_lines <- crop_roads(road_lines, x, circle_crop)
  }

  # Convert MULTILINESTRING to LINESTRING and ensure required columns
  roads <- convert_multilinestring_to_linestring(road_lines)
  roads <- ensure_required_columns(roads)

  return(roads)
}


# Building an Overpass query ----------------------------------------------

# Function to build an Overpass query
build_query <- function(...) {
  query_params <- list(...)

  # Generate bounding box (bbox) and search radius query string
  bbox_str   <- generate_bbox(query_params)
  radius_str <- generate_radius(query_params)

  # Define highway types as a regex pattern
  highway_types <- paste(pavement::osm_highway_values, collapse = "|")
  highway_regex <- sprintf("\"highway\"~\"^(%s)$\"", highway_types)

  # Construct Overpass query
  query_filters  <- sprintf("%s [%s]%s", radius_str, highway_regex, bbox_str)
  overpass_query <- sprintf("
  [out:xml][timeout:25];
  (
    node%s;
    way%s;
    relation%s;
  );
  (._;>;);
  out body;
  ", query_filters, query_filters, query_filters)

  # Store query parameters as an attribute
  attr(overpass_query, "query_params") <- query_params

  return(overpass_query)
}

# Generate bbox (bounding box) query string
generate_bbox <- function(params) {
  bbox <- params[["bbox"]]

  # Return an empty string if bbox is not provided
  if (is.null(bbox)) return("")

  sprintf("(%f,%f,%f,%f)",
          bbox['y', 'min'], bbox['x', 'min'],
          bbox['y', 'max'], bbox['x', 'max'])
}

# Generate search radius query string
generate_radius <- function(params) {
  rad <- params[["rad"]]
  lon <- params[["lon"]]
  lat <- params[["lat"]]

  # Return an empty string if any required parameter is missing
  if (is.null(rad) || is.null(lon) || is.null(lat)) return("")

  sprintf("(around:%s,%s,%s)", rad, lat, lon)
}


# Processing road data ----------------------------------------------------

# Create an empty roads sf object
create_empty_roads_sf <- function() {
  sf::st_sf(data.frame(
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
  is_reversed_idx <- which(!is.na(roads$oneway) & roads$oneway == -1)

  if (0 < length(is_reversed_idx)) {
    geoms <- sf::st_geometry(roads)
    geoms[is_reversed_idx] <- sf::st_reverse(geoms[is_reversed_idx])
    sf::st_geometry(roads) <- geoms
  }

  return(roads)
}

# Convert `oneway` column to a boolean vector
convert_oneway_to_boolean <- function(roads) {
  roads$oneway <- roads$oneway %in% c("yes", "-1")
  return(roads)
}

# Crop road data based on query parameters
crop_roads <- function(roads, query, circle_crop) {
  params <- attr(query, "query_params")
  crop_area <- determine_crop_area(params)

  roads <- sf::st_set_agr(roads, "constant")
  if (circle_crop) {
    sf::st_intersection(roads, crop_area)
  } else {
    sf::st_crop(roads, crop_area)
  }
}

# Determine the cropping area from query parameters
determine_crop_area <- function(params) {
  bbox <- params[["bbox"]]

  if (!is.null(bbox)) {
    crop_area <- sf::st_sfc(sf::st_polygon(list(rbind(
      c(bbox["x", "min"], bbox["y", "max"]),
      c(bbox["x", "max"], bbox["y", "max"]),
      c(bbox["x", "max"], bbox["y", "min"]),
      c(bbox["x", "min"], bbox["y", "min"]),
      c(bbox["x", "min"], bbox["y", "max"])
    ))), crs = 4326)

    return(crop_area)
  }

  rad <- params[["rad"]]
  lon <- params[["lon"]]
  lat <- params[["lat"]]

  if (!is.null(rad) && !is.null(lon) && !is.null(lat)) {
    center_point      <- sf::st_sfc(sf::st_point(c(lon, lat)), crs = 4326)
    transformed_point <- transform_to_cartesian(center_point)
    buffered_point    <- sf::st_buffer(transformed_point, dist = rad)
    crop_area         <- transform_to_geographic(buffered_point)

    return(crop_area)
  }

  stop("Either 'bbox' or 'rad', 'lon', and 'lat' must be provided.")
}

# Convert MULTILINESTRING to LINESTRING and generate unique IDs
convert_multilinestring_to_linestring <- function(roads) {
  roads_extracted <- sf::st_collection_extract(roads, "LINESTRING")

  roads_agr  <- sf::st_set_agr(roads_extracted, "constant")
  roads_cast <- sf::st_cast(roads_agr, "LINESTRING")

  roads_cast$id <- sprintf("rd_%04x", seq_len(nrow(roads_cast)))

  return(roads_cast)
}

# Ensure all required columns exist
ensure_required_columns <- function(roads) {
  empty_roads_sf <- create_empty_roads_sf()
  required_cols  <- names(empty_roads_sf)

  missing_cols <- setdiff(required_cols, names(roads))

  if (0 < length(missing_cols)) {
    for (col in missing_cols) {
      na_vector    <- rep(empty_roads_sf[[col]][NA_integer_], nrow(roads))
      roads[[col]] <- na_vector
    }
  }

  roads <- roads[, required_cols]
  rownames(roads) <- NULL

  return(roads)
}

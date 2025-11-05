#' Create processed OpenStreetMap road data for a given area
#'
#' @description
#' This is a convenient wrapper function that fetches road data from OpenStreetMap
#' for a specified bounding box, crops it, and transforms it to a Cartesian
#' coordinate system for analysis.
#'
#' @param north The northern latitude of the bounding box (e.g., 35.1886).
#' @param south The southern latitude of the bounding box (e.g., 35.1478).
#' @param east The eastern longitude of the bounding box (e.g., 136.9449).
#' @param west The western longitude of the bounding box (e.g., 136.8736).
#'
#' @return An `sf` object containing the processed road data, ready for use in
#'   functions like `create_road_network()`.
#' @export
#'
#' @examples
#' \dontrun{
#' # Get processed road data for a specific area in Nagoya
#' nagoya_roads <- create_osm_roads(
#'   north = 35.1886,
#'   south = 35.1478,
#'   east  = 136.9449,
#'   west  = 136.8736
#' )
#' plot(nagoya_roads$geometry)
#' }
create_osm_roads <- function(north, south, east, west) {

  # Create the bounding box object
  bounding_box <- create_bbox(
    north = north,
    south = south,
    east  = east,
    west  = west
  )

  # Fetch, crop, and transform the road data
  roads <- fetch_roads(
    bounding_box,
    overpass_url = "https://overpass-api.de/api/interpreter",
    crop = TRUE
  ) |>
    transform_to_cartesian()

  return(roads)
}

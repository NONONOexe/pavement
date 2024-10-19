#' Download and process OpenStreetMap road data
#'
#' This function downloads OpenStreetMap highway data within the specified
#' bounding box. It corrects the geometries of reversed one-way roads.
#' Optionally, it crops the data to the bounding box.
#'
#' @param bbox A bounding box in the form of a matrix with two rows and two
#'   columns.
#' @param crop A logical value indicating whether to crop the data to the
#'   bounding box. Defaults to `TRUE`.
#' @return A data frame containing OpenStreetMap road data.
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
fetch_roads <- function(bbox, crop = TRUE) {
  # Download OpenStreetMap highway data
  query <- add_osm_feature(
    opq(bbox),
    key   = "highway",
    value = osm_highway_values
  )
  data <- osmdata_sf(query)
  lines <- data$osm_lines

  # Correct the geometries of reversed one-way road
  is_reverse <- !is.na(lines$oneway) & lines$oneway == -1
  lines$geometry[is_reverse] <- st_reverse(lines$geometry[is_reverse])

  # Let `oneway` is boolean vector indicating one-way status
  lines$oneway <- lines$oneway %in% c("yes", "-1")

  # Crop to the specified bounding box
  if (crop) {
    lines <- st_set_agr(lines, "constant")
    area <- convert_bbox_to_polygon(bbox)
    lines <- st_crop(lines, area)
  }

  # Split "MULTILINESTRINGS" into individual "LINESTRING"
  lines <- st_set_agr(lines, "constant")
  lines <- st_cast(lines, "LINESTRING")
  lines$id <- sprintf("rd_%04x", seq_len(nrow(lines)))
  roads <- st_set_agr(lines, "constant")
  row.names(roads) <- NULL

  return(roads[c("id", "highway", "name", "layer", "oneway", "osm_id")])
}

#' Transform to Cartesian or geographic coordinates
#'
#' This function transforms a spatial object to Cartesian coordinates (plane
#' rectangular coordinate system) or geographic coordinates (WGS84; EPSG:4326).
#' The Cartesian system currently supports only Aichi Prefecture's JDG2011
#' system (EPSG:6675).
#'
#' If the CRS is missing (NA), a warning is issued, and the original object is
#' returned. The warning can be suppressed with the `quiet` argument.
#'
#' @name transform_coordinates
#' @param spatial_object A spatial object.
#' @param target A character string specifying the target coordinate system:
#'   `"cartesian"` (EPSG:6675) or `"geographic"` (EPSG:4326).
#' @param quiet Logical. If `TRUE`, suppresses the warning when CRS is missing.
#' @return A spatial object transformed to the specified coordinate system.
#' @export
#' @examples
#' # Create points
#' points <- create_points(136.9024, 35.1649, crs = 4326)
#' points
#'
#' # Transform to Cartesian coordinates
#' transformed <- transform_to_cartesian(points)
#' transformed
#'
#' # Transform to geographic coordinates
#' transformed <- transform_to_geographic(points)
#' transformed
NULL

#' @rdname transform_coordinates
#' @export
transform_coordinates <- function(spatial_object,
                                  target = c("cartesian", "geographic"),
                                  quiet = FALSE) {
  target <- match.arg(target)

  epsg_codes <- list(
    cartesian  = 6675, # Aichi Prefecture JDG2011
    geographic = 4326  # WGS84
  )

  # Check for missing CRS
  crs_info <- sf::st_crs(spatial_object)
  if (is.na(crs_info$input)) {
    if (!quiet) {
      cli::cli_warn("CRS is missing. Returning the input object without transformation.")
    }
    return(spatial_object)
  }

  # Perform the transformation
  transformed <- sf::st_transform(spatial_object, epsg_codes[[target]])

  return(transformed)
}

#' @rdname transform_coordinates
#' @export
transform_to_cartesian <- function(spatial_object, quiet = FALSE) {
  transform_coordinates(spatial_object, target = "cartesian", quiet = quiet)
}

#' @rdname transform_coordinates
#' @export
transform_to_geographic <- function(spatial_object, quiet = FALSE) {
  transform_coordinates(spatial_object, target = "geographic", quiet = quiet)
}

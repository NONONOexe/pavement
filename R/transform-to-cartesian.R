#' Transform to Cartesian coordinates
#'
#' This function transforms a spatial object to Cartesian coordinates (plane
#' rectangular coordinate system). Currently, it supports the coordinate
#' system used in Aichi Prefecture (JDG2011, EPSG:6675).
#'
#' @param x A spatial object.
#' @return A spatial object transformed to Cartesian coordinates.
#' @seealso [transform_to_geographic()] to transform to geographic coordinates.
#' @export
#' @examples
#' # Create points
#' points <- create_points(136.9024, 35.1649, crs = 4326)
#' points
#'
#' # Transform to Cartesian coordinates
#' transformed <- transform_to_cartesian(points)
#' transformed
transform_to_cartesian <- function(x) {
  transformed <- st_transform(x, 6675)

  return(transformed)
}

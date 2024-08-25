#' Transform to geographic coordinates
#'
#' This function transforms a spatial object to geographic coordinates
#' (WGS84, EPSG:4326).
#'
#' @param x A spatial object.
#' @return A spatial object transformed to geographic coordinates.
#' @seealso [transform_to_cartesian()] to transform to Cartesian coordinates.
#' @export
transform_to_geographic <- function(x) {
  transformed <- st_transform(x, 4326)

  return(transformed)
}

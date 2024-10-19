#' Convert a bounding box to coordinates or a polygon
#'
#' This function converts a bounding box to either coordinates or a polygon.
#'
#' @param bbox A numeric matrix with two columns and two rows.
#'   `bbox` represents the minimum and maximum coordinates.
#'   The bounding box can be created using the `create_bbox` function.
#' @param output A string specifying the output type. Either "coordinates" or
#'   "polygon".
#' @param crs A string specifying the coordinate reference system. This is
#'   only used when converting to a polygon.
#' @return A `coordinates` object or a `sfc` polygon object.
#' @export
#' @examples
#' bbox <- create_bbox(center_lon = 136.9024,
#'                     center_lat =  35.1649,
#'                     width      = 0.10,
#'                     height     = 0.05)
#' convert_bbox_to_coordinates(bbox)
#' convert_bbox_to_polygon(bbox, crs = 4326)
convert_bbox <- function(bbox,
                         output = c("coordinates", "polygon"),
                         crs = NULL) {
  output <- match.arg(output)

  if (output == "coordinates") {
    return(convert_bbox_to_coordinates(bbox))
  } else if (output == "polygon") {
    return(convert_bbox_to_polygon(bbox, crs))
  }
}

#' @rdname convert_bbox
#' @export
convert_bbox_to_coordinates <- function(bbox) {
  top_left <- bbox[, 1]
  bottom_right <- bbox[, 2]
  top_right <- c(top_left[1], bottom_right[2])
  bottom_left <- c(bottom_right[1], top_left[2])

  coordinates <- create_coordinates(
    top_left,
    bottom_left,
    bottom_right,
    top_right
  )

  return(coordinates)
}

#' @rdname convert_bbox
#' @export
convert_bbox_to_polygon <- function(bbox, crs = NULL) {
  coordinates <- convert_bbox_to_coordinates(bbox)
  if (is.null(crs) || is.na(crs)) crs <- "NA"

  return(create_polygon.coordinates(coordinates, crs))
}

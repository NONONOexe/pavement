#' Convert a bounding box to a polygon
#'
#' This function convert a bounding box to a polygon.
#'
#' @param bbox A numeric matrix with two columns and two rows.
#'   `bbox` represents the minimum and maximum coordinates.
#' @return A rectangle polygon with the same size as `bbox`.
#' @export
bbox_to_polygon <- function(bbox) {
  tl <- bbox[,1]
  br <- bbox[,2]
  tr <- c(tl[1], br[2])
  bl <- c(br[1], tl[2])
  polygon <- structure(
    list(rbind(tl, bl, br, tr, tl)),
    class = c("XY", "POLYGON", "sfg")
  )

  return(polygon)
}

globalVariables("jdg2011_datum")

#' Japan Geodetic Datum 2011 (JDG2011) Reference Points
#'
#' A dataset representing reference points for Japan Geodetic Datum 2011
#' (JDG2011). This dataset contains system numbers, longitude, latitude,
#' and corresponding coordinate reference system (CRS) codes for various
#' geodetic reference points in Japan.
#'
#' @format A `data.frame` with 19 rows and 4 columns:
#' \describe{
#'   \item{system_no}{System number (Roman numeral I-XIX) representing geodetic
#'     reference zones}
#'   \item{lon}{Longitude in decimal degrees}
#'   \item{lat}{Latitude in decimal degrees}
#'   \item{crs}{Coordinate reference system (CRS) code for reference point}
#' }
#' @examples
#' # Show the dataset
#' jdg2011_datum
#'
#' @name jdg2011_datum
"jdg2011_datum"

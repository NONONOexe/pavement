#' Sample accident data for five years
#'
#' Synthetic traffic accident data over five years.
#'
#' @format An \code{sf} object with 50 rows and 6 variables:
#' \describe{
#'   \item{id}{Unique accident identifier (character).}
#'   \item{time}{Time of the accident (integer, hour of day).}
#'   \item{weather}{Weather condition (factor: "Sunny", "Cloudy", "Rainy", "Foggy", "Snowy").}
#'   \item{severity}{Severity of accident (factor: "Minor", "Serious", "Fatal").}
#'   \item{geometry}{Spatial point location (\code{sfc_POINT}).}
#'   \item{year}{Year of occurrence (integer, 1–5).}
#' }
#' @examples
#' sample_accidents_multiyear
"sample_accidents_multiyear"

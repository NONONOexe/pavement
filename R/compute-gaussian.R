#' Compute the Gaussian function
#'
#' The Gaussian function is a bell-shaped function defined as follows:
#' \deqn{
#'   K(x) =
#'     \frac{1}{\sqrt{2\pi\sigma^2}}
#'     \exp\left( -\frac{x^2}{2\sigma^2} \right)\text{.}
#' }
#'
#' @param x A numric vector.
#' @param sigma The standard deviation of the Gaussian function.
#' @return A numeric vector of weights of the kernel for each input points.
#' @export
#' @examples
#' x <- seq(-3, 3, 0.1)
#' y <- compute_gaussian(x, sigma = 1)
#' plot(x, y, xlim = c(-3, 3), ylim = c(0, 1), type = "l")
compute_gaussian <- function(x, sigma = 1) {
  return(1 / sqrt(2 * pi * sigma^2) * exp(-x^2 / (2 * sigma^2)))
}

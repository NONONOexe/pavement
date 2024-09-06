#' Epanechnikov kernel
#'
#' The kernel is one of the quadratic kernels used
#' in kernel density estimation.
#'
#' Epanechnikov kernel is defined as follows:
#' \loadmathjax
#' \mjdeqn{
#'   K(x) = \frac{3}{4}(1 - x^2) \quad \text{if} \quad |x| \leq 1
#' }{ascii}
#'
#' @param x A numeric vector.
#' @return A numeric vector of weights of the kernel for each input points.
#' @export
#' @examples
#' x <- seq(-3, 3, 0.1)
#' y <- calculate_weights_epanechnikov(x)
#' plot(x, y, type = "l")
calculate_weights_epanechnikov <- function(x) {
  return(ifelse(abs(x) <= 1, (3 / 4) * (1 - x^2), 0))
}

#' Compute the Epanechnikov function
#'
#' The Epanechnikov function is one of the quadratic kernels used in
#' kernel density estimation. It is defined as follows:
#' \deqn{K(x) = \frac{3}{4}(1 - x^2) \quad \text{if} \quad |x| \leq 1\text{.}}
#'
#' @param x A numeric vector.
#' @return A numeric vector of weights of the kernel for each input points.
#' @export
#' @examples
#' x <- seq(-3, 3, 0.1)
#' y <- compute_epanechnikov(x)
#' plot(x, y, xlim = c(-3, 3), ylim = c(0, 1), type = "l")
compute_epanechnikov <- function(x) {
  return(ifelse(abs(x) <= 1, (3 / 4) * (1 - x^2), 0))
}

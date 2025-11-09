# Compute the Gaussian function

The Gaussian function is a bell-shaped function defined as follows: \$\$
K(x) = \frac{1}{\sqrt{2\pi\sigma^2}} \exp\left( -\frac{x^2}{2\sigma^2}
\right)\text{.} \$\$

## Usage

``` r
compute_gaussian(x, sigma = 1)
```

## Arguments

- x:

  A numric vector.

- sigma:

  The standard deviation of the Gaussian function.

## Value

A numeric vector of weights of the kernel for each input points.

## Examples

``` r
x <- seq(-3, 3, 0.1)
y <- compute_gaussian(x, sigma = 1)
plot(x, y, xlim = c(-3, 3), ylim = c(0, 1), type = "l")
```

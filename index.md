# pavement

## Overview

pavement is a package designed to analyze spatial events occurring on
roadways. It provides comprehensive toolkit for working with spatial
data, empowering users to understand patterns and trends in road-related
phenomena.

## Installation

You can install the development version of pavement using the following
methods:

### Using `install.packages()` (R-universe)

``` r
# Enable the R-universe
options(repos = c(
  nononoexe = "https://nononoexe.r-universe.dev",
  cran = "https://cloud.r-project.org"
))

# Install the package
install.packages("pavement")
```

### Using `pak`

``` r
# install.packages("pak")
pak::pak("nononoexe/pavement")
```

## Usage

This example demonstrates how to visualize the distribution of roads and
traffic accidents using pavement:

``` r
library(pavement)

segmented_network <- sample_roads |>
  create_road_network() |>
  set_events(sample_accidents) |>
  create_segmented_network(segment_length = 0.5) |>
  convolute_segmented_network()
```

``` r
plot(segmented_network, mode = "event")
```

![A map showing a road network with individual points plotted along the
lines, representing the locations of traffic
accidents.](reference/figures/README-plot-event-1.png)

``` r
plot(segmented_network, mode = "count")
```

![A map of a road network where each road segment is colored according
to number of accidents it contains. Colors range from yellow for low
counts to red for high counts, indicating accident
hotspots.](reference/figures/README-plot-count-1.png)

``` r
plot(segmented_network, mode = "density")
```

![A map of a road network with a smooth color gradient along the roads,
representing the kernel density of accident. The color transitions from
yellow in low-density areas to red in high-density areas, highlighting
hotspots.](reference/figures/README-plot-density-1.png)

## Code of conduct

Please note that this project is released with a [Contributor Code of
Conduct](https://nononoexe.github.io/pavement/CODE_OF_CONDUCT.html). By
participating in this project you agree to abide by its terms.

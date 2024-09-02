
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pavement <img src="man/figures/logo.png" align="right" width="138" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/pavement)](https://CRAN.R-project.org/package=pavement)
[![Codecov test
coverage](https://codecov.io/gh/NONONOexe/pavement/branch/main/graph/badge.svg)](https://app.codecov.io/gh/NONONOexe/pavement?branch=main)
<!-- badges: end -->

## Overview

pavement is a package designed to analyze spatial events occurring on
roadways. It provides comprehensive toolkit for working with spatial
data, empowering users to understand patterns and trends in road-related
phenomena.

## Installation

You can install the development version of pavement from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("NONONOexe/pavement")
```

## Usage

This example demonstrates how to visualize the distribution of roads and
traffic accidents using pavement:

``` r
library(pavement)

segmented_network <- sample_roads |>
  create_road_network() |>
  create_segmented_network(segment_length = 0.5) |>
  assign_event_to_link(events = sample_accidents)
plot(segmented_network, mode = "event")
```

<img src="man/figures/README-example-1.png" width="100%" />

``` r
plot(segmented_network, mode = "count")
```

<img src="man/figures/README-example-2.png" width="100%" />

## Code of conduct

Please note that this project is released with a [Contributor Code of
Conduct](https://nononoexe.github.io/pavement/CODE_OF_CONDUCT.html). By
participating in this project you agree to abide by its terms.

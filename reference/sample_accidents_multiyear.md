# Sample accident data for five years

Synthetic traffic accident data over five years.

## Usage

``` r
sample_accidents_multiyear
```

## Format

An `sf` object with 50 rows and 6 variables:

- id:

  Unique accident identifier (character).

- time:

  Time of the accident (integer, hour of day).

- weather:

  Weather condition (factor: "Sunny", "Cloudy", "Rainy", "Foggy",
  "Snowy").

- severity:

  Severity of accident (factor: "Minor", "Serious", "Fatal").

- geometry:

  Spatial point location (`sfc_POINT`).

- year:

  Year of occurrence (integer, 1–5).

## Examples

``` r
sample_accidents_multiyear
#> Simple feature collection with 50 features and 5 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 1 ymin: 0.4 xmax: 7.4 ymax: 3.4
#> CRS:           NA
#> First 10 features:
#>          id time weather severity year        geometry
#> 1  ac1_0001    6   Sunny    Minor    1     POINT (1 1)
#> 2  ac1_0002    9  Cloudy    Minor    1 POINT (2.2 0.4)
#> 3  ac1_0003   12   Rainy  Serious    1 POINT (3.1 2.1)
#> 4  ac1_0004   15   Foggy    Minor    1 POINT (4.7 2.8)
#> 5  ac1_0005   18   Sunny    Fatal    1 POINT (5.2 1.4)
#> 6  ac1_0006   21   Rainy    Minor    1 POINT (5.8 2.5)
#> 7  ac1_0007   23   Sunny  Serious    1   POINT (6 1.2)
#> 8  ac1_0008    2   Snowy    Minor    1 POINT (6.3 0.8)
#> 9  ac1_0009    4   Sunny    Minor    1 POINT (6.7 2.4)
#> 10 ac1_000a    8  Cloudy    Fatal    1   POINT (7 2.9)
```

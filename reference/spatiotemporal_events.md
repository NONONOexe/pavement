# Create a spatiotemporal event collection

This function creates a spatiotemporal event collection object from a
given `sf` object, allowing spatial and temporal data to be handled
together.

## Usage

``` r
create_spatiotemporal_events(x, ...)

# S3 method for class 'sf'
create_spatiotemporal_events(
  x,
  time_column_name = "time",
  time_format = "%H",
  ...
)
```

## Arguments

- x:

  A `sf` object representing the spatial data.

- ...:

  Additional arguments passed to or from other methods.

- time_column_name:

  A character string specifying the column name in `x` that contains
  time-related data. Defaults to `"time"`

- time_format:

  A character string specifying the format of the time data in the
  `time_column_name`. For example, you can use formats like `"%Y-%m-%d"`
  for dates or `"%H:%M:%S"` for time. Defaults to `"%H"`.

## Value

An `sf` object with class `spatiotemporal_events` added, representing a
spatiotemporal event collection.

## Examples

``` r
# Simple feature collection object representing accidents
sample_accidents
#> Simple feature collection with 10 features and 4 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 1 ymin: 0.4 xmax: 6.5 ymax: 3.1
#> CRS:           NA
#>         id time weather severity        geometry
#> 1  ac_0001   18   Sunny    Minor     POINT (1 1)
#> 2  ac_0002    4   Foggy    Fatal POINT (3.2 0.4)
#> 3  ac_0003   13   Snowy    Minor POINT (4.1 3.1)
#> 4  ac_0004   23   Sunny    Minor POINT (5.7 3.1)
#> 5  ac_0005    7   Rainy    Minor POINT (5.9 1.1)
#> 6  ac_0006    7   Sunny    Minor     POINT (6 3)
#> 7  ac_0007   19  Cloudy    Minor POINT (6.1 0.9)
#> 8  ac_0008    8   Sunny    Minor POINT (6.1 1.2)
#> 9  ac_0009   19   Rainy  Serious POINT (6.2 2.9)
#> 10 ac_000a   20   Sunny    Minor   POINT (6.5 3)

# Create a spatiotemporal event collection
create_spatiotemporal_events(sample_accidents)
#> Spatiotemporal event collection with 10 events and 3 fields
#> Geometry type: POINT
#> Time column:   time
#> Time format:   %H
#> Data:
#>        id time weather severity        geometry
#> 1 ac_0001   18   Sunny    Minor     POINT (1 1)
#> 2 ac_0002    4   Foggy    Fatal POINT (3.2 0.4)
#> 3 ac_0003   13   Snowy    Minor POINT (4.1 3.1)
#> 4 ac_0004   23   Sunny    Minor POINT (5.7 3.1)
#> 5 ac_0005    7   Rainy    Minor POINT (5.9 1.1)
#> ... 5 more events
```

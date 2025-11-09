# Sample roads data

A sample dataset representing simple roads. It intended for
demonstration and testing and does not represent real-world roads.

## Usage

``` r
sample_roads
```

## Format

A `sf` linestring object with 6 rows and 2 columns:

- id:

  Road ID

- layer:

  Layer of the road (indicates a road on an elevated structure such as a
  bridge, tunnel, or highway)

- geometry:

  Linestring geometry of the road

## Examples

``` r
# Show information about the roads
sample_roads
#> Simple feature collection with 6 features and 2 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 0 xmax: 7 ymax: 5
#> CRS:           NA
#>        id layer                       geometry
#> 1 rd_0001     1     LINESTRING (0 0, 3 0, 4 3)
#> 2 rd_0002    NA          LINESTRING (0 1, 7 1)
#> 3 rd_0003    NA LINESTRING (2 3, 1 4, 0 3, ...
#> 4 rd_0004    NA          LINESTRING (2 3, 4 3)
#> 5 rd_0005    NA          LINESTRING (4 3, 7 3)
#> 6 rd_0006    NA          LINESTRING (6 0, 6 5)

# Shape of the roads
plot(sample_roads$geometry)
```

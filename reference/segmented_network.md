# Create a segmented road network

This function creates a segmented road network by dividing each link of
the input road network into segments of a specified length.

## Usage

``` r
create_segmented_network(road_network, segment_length = 1, events = NULL, ...)

# S3 method for class 'road_network'
create_segmented_network(road_network, segment_length = 1, events = NULL, ...)
```

## Arguments

- road_network:

  A `road_network` object representing the input road network.

- segment_length:

  A numeric value specifying the length of each segment.

- events:

  A `sf` object representing events.

- ...:

  Additional arguments passed to or from other methods.

## Value

A `segmented_network` object.

## Examples

``` r
# Create a road network
road_network <- create_road_network(sample_roads)

# Create a segmented road network
segmented_network <- create_segmented_network(
  road_network,
  segment_length = 0.5
)
segmented_network
#> Segmented network
#> Segment length:  0.5
#> Segments:
#>            id        from          to parent_link parent_road count density
#> 1 sl_00000001 sn_00000001 sn_00000004   lk_000001     rd_0001     0       0
#> 2 sl_00000002 sn_00000004 sn_00000005   lk_000001     rd_0001     0       0
#> 3 sl_00000003 sn_00000005 sn_00000006   lk_000001     rd_0001     0       0
#> 4 sl_00000004 sn_00000006 sn_00000007   lk_000001     rd_0001     0       0
#> 5 sl_00000005 sn_00000007 sn_00000008   lk_000001     rd_0001     0       0
#>                         geometry
#> 1  LINESTRING (0 0, 0.5135231 0)
#> 2 LINESTRING (0.5135231 0, 1....
#> 3 LINESTRING (1.027046 0, 1.5...
#> 4 LINESTRING (1.540569 0, 2.0...
#> 5 LINESTRING (2.054093 0, 2.5...
#> ... 52 more segments

# Plot the segmented road network
plot(segmented_network)
```

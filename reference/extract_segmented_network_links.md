# Extract segmented network links from a road network

This function extracts the segmented network links from a road network
based on a specified set of segmented network nodes. It splits the
linestrings of the road network links at the points of the segmented
network nodes to create the segmented network links.

## Usage

``` r
extract_segmented_network_links(
  road_network,
  segmented_network_nodes,
  tolerance = 1e-05
)
```

## Arguments

- road_network:

  A `road_network` object created with
  [`create_road_network()`](https://nononoexe.github.io/pavement/reference/road_network.md)

- segmented_network_nodes:

  A data frame representing the segmented network nodes.

- tolerance:

  A numeric value representing the maximum distance allowed between a
  linestring of a road link and a point of a segmented network node. If
  the distance exceeds this value, the point will not be used to split
  the linestring.

## Value

A data frame representing the segmented network links.

## Examples

``` r
# Create a road network
road_network <- create_road_network(sample_roads)

# Extract segmented network nodes by length of 1
segmented_network_nodes <- extract_segmented_network_nodes(road_network, 1)

# Extract segmented network links
segmented_network_links <- extract_segmented_network_links(
  road_network,
  segmented_network_nodes
)
segmented_network_links
#> Simple feature collection with 29 features and 7 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 0 xmax: 7 ymax: 5
#> CRS:           NA
#> First 10 features:
#>             id        from          to parent_link parent_road count density
#> 1  sl_00000001 sn_00000001 sn_00000004   lk_000001     rd_0001     0       0
#> 2  sl_00000002 sn_00000004 sn_00000005   lk_000001     rd_0001     0       0
#> 3  sl_00000003 sn_00000005 sn_00000006   lk_000001     rd_0001     0       0
#> 4  sl_00000004 sn_00000006 sn_00000007   lk_000001     rd_0001     0       0
#> 5  sl_00000005 sn_00000007 sn_00000008   lk_000001     rd_0001     0       0
#> 6  sl_00000006 sn_00000008 sn_00000002   lk_000001     rd_0001     0       0
#> 7  sl_00000007 sn_00000009 sn_0000000a   lk_000002     rd_0002     0       0
#> 8  sl_00000008 sn_0000000b sn_0000000d   lk_000003     rd_0002     0       0
#> 9  sl_00000009 sn_0000000d sn_0000000e   lk_000003     rd_0002     0       0
#> 10 sl_0000000a sn_0000000e sn_0000000f   lk_000003     rd_0002     0       0
#>                          geometry
#> 1    LINESTRING (0 0, 1.027046 0)
#> 2  LINESTRING (1.027046 0, 2.0...
#> 3  LINESTRING (2.054093 0, 3 0...
#> 4  LINESTRING (3.025658 0.0769...
#> 5  LINESTRING (3.350439 1.0513...
#> 6  LINESTRING (3.675219 2.0256...
#> 7           LINESTRING (6 1, 7 1)
#> 8           LINESTRING (0 1, 1 1)
#> 9           LINESTRING (1 1, 2 1)
#> 10          LINESTRING (2 1, 3 1)

# Plot the segmented network nodes and links
plot(segmented_network_links$geometry, col = "#E69F00")
plot(segmented_network_nodes$geometry, pch = 16, add = TRUE)
```

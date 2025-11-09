# Decompose a linestring into a list of line segments

This function decomposes a linestring into a list of line segments,
where each segment is a linestring connecting two consecutive points of
the input linestring.

## Usage

``` r
decompose_linestring(linestring)
```

## Arguments

- linestring:

  A linestring object.

## Value

A list of linestring objects, each representing a segment of the input
linestring.

## Examples

``` r
# Create a linestring object
linestring <- create_linestring(0, -1, 0, 1, 2, 1, 2, 0, 0, 0)
plot(linestring)


# Decompose the linestring into line segments
segments <- decompose_linestring(linestring)
plot(segments, col = c("#E69F00", "#56B4E9", "#009E73", "#F0E442"))
```

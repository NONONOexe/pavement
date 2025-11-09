# Split multiple linestrings into segments

Split multiple linestrings into segments

## Usage

``` r
split_linestrings(linestrings, split_points, tolerance = 0.01)
```

## Arguments

- linestrings:

  An `sfc` object containing `LINESTRING` geometries, or a single
  linestring geometry.

- split_points:

  An `sfc` object containing `MULTIPOINT` geometries, (one per
  linestring), or a set of `POINT`/`MULTIPOINT` geometries for a single
  `LINESTRING`.

- tolerance:

  A numeric value representing the maximum distance allowed between a
  linestring and its split points. Points beyond this tolerance will be
  ignored.

## Value

If the input is a single `LINESTRING`, returns an `sfc` of
`LINESTRING`s. If the input is multiple `LINESTRING`s, returns a list of
`sfc` objects, one for each input `LINESTRING`.

## Examples

``` r
# Single `LINESTRING`
line   <- create_linestring(0, 0, 0, 2, 2, 2, 2, 1, 0, 1)
points <- create_points(0, 1, 1, 2, 2, 1, as_multipoint = TRUE)
plot(line)
plot(points, add = TRUE)


segments <- split_linestrings(line, points)[[1]]
plot(segments, col = c("#E69F00", "#56B4E9", "#009E73", "#F0E442"), lwd = 2)


# Multiple `LINESTRING`s
lines  <- c(create_linestring(0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 2.0, 1.0, 0.0,
                              1.0),
            create_linestring(2.5, 1.0, 3.5, 1.0, 3.5, 0.0, 2.5, 0.0, 2.5,
                              0.5, 3.5, 0.5))
points <- c(create_points(0.0, 1.0, 1.0, 2.0, 2.0, 1.0,
                          as_multipoint = TRUE),
            create_points(2.5, 0.5,
                          as_multipoint = TRUE))
plot(lines)
plot(points, add = TRUE)


segments <- do.call(c, split_linestrings(lines, points))
plot(segments,
     col = c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2",
             "#D55E00"),
     lwd = 2)

```

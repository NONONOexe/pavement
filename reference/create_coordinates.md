# Create a collection of coordinates.

This function creates a collection of coordinates from a sequence x and
y coordinates.

## Usage

``` r
create_coordinates(...)
```

## Arguments

- ...:

  A sequence of x and y coordinates.

## Value

A `coordinates` object which is a matrix with x and y columns.

## Examples

``` r
# Create a `coordinates` object from a sequence of x and y coordinates
create_coordinates(1, 2, 3, 4)
#> {(1, 2), (3, 4)}

# Create a `coordinates` object from an with a vector of x and y
# coordinates
create_coordinates(c(1, 2, 3, 4))
#> {(1, 2), (3, 4)}
```

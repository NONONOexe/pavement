# Set events on a space.

This function sets events on a space.

## Usage

``` r
set_events(x, events, ...)
```

## Arguments

- x:

  A space object.

- events:

  A sf or spatiotemporal events object.

- ...:

  Additional arguments passed to or from other methods.

## Value

The input object with the events added.

## Examples

``` r
# Create the road network
road_network <- create_road_network(sample_roads)

# Set accidents on the road network
road_network <- set_events(road_network, sample_accidents)
```

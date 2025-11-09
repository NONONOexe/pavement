# Find the index of the duration that contains the event time

This function find the index of the duration that contains the event
time.

## Usage

``` r
find_duration(events, durations, ...)
```

## Arguments

- events:

  A spatiotemporal event object.

- durations:

  A duration object.

- ...:

  Additional arguments passed to or from other methods.

## Value

A vector of indices corresponding to the durations that contain the
event times.

## Examples

``` r
# Create a spatiotemporal event object
accidents <- create_spatiotemporal_events(sample_accidents)

# Create a duration object
durations <- create_durations("1 hour")

# Find the duration that contains each accident
find_duration(accidents, durations)
#>  [1] 19  5 14 24  8  8 20  9 20 21
```

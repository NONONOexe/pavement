# Test for temporal consistency of spatio-temporal properties

This function evaluates the temporal consistency of Local Moran's I
cluster classifications for each spatio-temporal unit (spatiotemporal
segment) across multiple years.

## Usage

``` r
test_spatio_properties(list_of_moran_results, p_value_threshold = 0.05)
```

## Arguments

- list_of_moran_results:

  A list where each element is the output of `calculate_local_moran` for
  a specific year.

- p_value_threshold:

  The p-value cutoff to determine consistency (default: 0.05).

## Value

A data frame summarizing the consistency test for each spatiotemporal
segment.

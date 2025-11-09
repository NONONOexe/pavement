# Run the full spatio-temporal consistency test

`run_consistency_test()` evaluates the temporal consistency of Local
Moran's I cluster classifications across multiple years. The input
accident data can be either:

- A single data.frame containing a `year` column with multiple years of
  data.

- A list of `sf` data frames, each representing a separate year.

The function calculates Local Moran's I for each year and then tests the
consistency of classifications over time.

## Usage

``` r
run_consistency_test(
  network_object,
  accident_data,
  dist_threshold = 1,
  time_threshold = 2,
  p_value_threshold = 0.05,
  time_column = "time",
  year_column = "year"
)
```

## Arguments

- network_object:

  A base network object, either `segmented_network` or
  `spatiotemporal_network`.

- accident_data:

  Either:

  - A data.frame containing accident records for multiple years (must
    include a `year` column).

  - A list of `sf` data frames, one per year.

- dist_threshold:

  The spatial distance threshold for `calculate_local_moran`.

- time_threshold:

  The temporal distance threshold for `calculate_local_moran`.

- p_value_threshold:

  The p-value cutoff for the final consistency test.

- time_column:

  The name of the column in the accident data that contains the time
  information (e.g., "occurrence_hour"). Defaults to `"time"`.

- year_column:

  The name of the column indicating the year in `accident_data` (if
  data.frame). Defaults to `"year"`.

## Value

A data frame with the final consistency test results.

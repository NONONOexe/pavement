# Generate unique IDs based on parent IDs

This function generates unique IDs based on parent IDs. It first
extracts the first ID from each parent ID, then ranks these IDs and uses
the ranks to format the IDs.

## Usage

``` r
generate_ids(parent_list, id_format)
```

## Arguments

- parent_list:

  A list of parent IDs.

- id_format:

  A format string for the IDs.

## Value

A vector of unique IDs.

## Examples

``` r
parent_list <- c("rd_0001", "rd_0002", "rd_0003")
id_format <- "jn_%06x"
generate_ids(parent_list, id_format)
#> [1] "jn_000001" "jn_000002" "jn_000003"
```

# Helper function to find the mode (most frequent value) of a vector
get_mode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}


#' Test for temporal consistency of spatio-temporal properties
#'
#' @description
#' This is the main testing function that takes a list of Local Moran's I results
#' (one for each year/period) and evaluates the temporal consistency of the
#' cluster classification (e.g., High-High, Low-Low) for each spatio-temporal
#' unit (arixel).
#'
#' @param list_of_moran_results A list where each element is the output of
#'   `calculate_local_moran` for a specific year.
#' @param p_value_threshold The p-value cutoff to determine if a cluster's
#'   classification is temporally consistent (default: 0.05).
#'
#' @return A data frame summarizing the consistency test for each arixel.
#' @export
test_spatio_properties <- function(list_of_moran_results, p_value_threshold = 0.05) {

  # Combine all yearly data into a single data frame
  all_years_data <- dplyr::bind_rows(
    lapply(seq_along(list_of_moran_results), function(i) {
      moran_result <- list_of_moran_results[[i]]
      moran_result$moran_results |> dplyr::mutate(year = i)
    })
  )

  # Group by spatio-temporal unit and test for consistency
  consistency_results <- all_years_data |>
    dplyr::group_by(segment_id, time) |>
    dplyr::summarise(
      most_likely_class = get_mode(classification),
      n_years = dplyr::n(),
      mismatch_count_k = sum(classification != most_likely_class),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      # Use a binomial test to see if the number of mismatches is surprisingly high
      p_value = pbinom(mismatch_count_k, size = n_years, prob = 3/4),
      is_consistent = p_value <= p_value_threshold
    )

  return(consistency_results)
}


#' Run the full spatio-temporal consistency test
#'
#' @description
#' A convenient wrapper function that combines all processing steps. It takes a
#' base network and a list of event datasets, runs `calculate_local_moran` for
#' each dataset, and then calls `test_spatio_properties` to evaluate the
#' temporal consistency of the resulting clusters.
#'
#' @param network_object A base network object, either of class
#'   `segmented_network` or `spatiotemporal_network`.
#' @param list_of_accidents A list of `sf` data frames, where each element
#'   represents event data for a specific year or time period.
#' @param dist_threshold The spatial distance threshold for `calculate_local_moran`.
#' @param time_threshold The temporal distance threshold for `calculate_local_moran`.
#' @param p_value_threshold The p-value cutoff for the final consistency test.
#'

#' @return A data frame with the final consistency test results from
#'   `test_spatio_properties`.
#' @export
run_consistency_test <- function(network_object,
                                 list_of_accidents,
                                 dist_threshold = 1,
                                 time_threshold = 2,
                                 p_value_threshold = 0.05) {

  # Iterate through each year's accident data, set events, and calculate Moran's I
  list_of_moran_results <- lapply(list_of_accidents, function(accidents_data) {
    network_object |>
      set_events(accidents_data) |>
      calculate_local_moran(
        dist_threshold = dist_threshold,
        time_threshold = time_threshold
      )
  })

  # Run the final consistency test on the list of Moran's I results
  final_results <- test_spatio_properties(
    list_of_moran_results,
    p_value_threshold = p_value_threshold
  )

  return(final_results)
}


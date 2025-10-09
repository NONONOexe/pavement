# Helper function to find the mode (most frequent value) of a vector
get_mode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}


#' Test for temporal consistency of spatio-temporal properties
#'
#' @description
#' This function evaluates the temporal consistency of Local Moran's I cluster
#' classifications for each spatio-temporal unit (spatiotemporal_segement) across multiple years.
#'
#' @param list_of_moran_results A list where each element is the output of
#'   `calculate_local_moran` for a specific year.
#' @param p_value_threshold The p-value cutoff to determine consistency (default: 0.05).
#'
#' @return A data frame summarizing the consistency test for each spatiotemporal_segement.
#' @export
test_spatio_properties <- function(list_of_moran_results, p_value_threshold = 0.05) {

  # Combine all yearly data into a single data frame
  all_years_data <- do.call(
    rbind,
    lapply(seq_along(list_of_moran_results), function(i) {
      moran_result <- list_of_moran_results[[i]]
      cbind(moran_result$moran_results, year = i)
    })
  )

  # Split data by (segment_id, time)
  split_data <- split(
    all_years_data,
    list(all_years_data$segment_id, all_years_data$time),
    drop = TRUE
  )

  # Apply consistency test for each group
  consistency_list <- lapply(split_data, function(df) {
    most_likely_class <- get_mode(df$classification)
    n_years <- nrow(df)
    mismatch_count_k <- sum(df$classification != most_likely_class)

    p_value <- stats::pbinom(mismatch_count_k, size = n_years, prob = 3/4)
    is_consistent <- p_value <= p_value_threshold

    data.frame(
      segment_id = df$segment_id[1],
      time = df$time[1],
      most_likely_class = most_likely_class,
      n_years = n_years,
      mismatch_count_k = mismatch_count_k,
      p_value = p_value,
      is_consistent = is_consistent,
      stringsAsFactors = FALSE
    )
  })

  consistency_results <- do.call(rbind, consistency_list)
  rownames(consistency_results) <- NULL
  return(consistency_results)
}


#' Run the full spatio-temporal consistency test
#'
#' @description
#' This function evaluates the temporal consistency of Local Moran's I cluster
#' classifications across multiple years. The input accident data can be either:
#' \itemize{
#'   \item A single data.frame containing a `year` column with multiple years of data.
#'   \item A list of `sf` data frames, each representing a separate year.
#' }
#' The function calculates Local Moran's I for each year and then tests the
#' consistency of classifications over time.
#'
#' @param network_object A base network object, either `segmented_network` or `spatiotemporal_network`.
#' @param accident_data Either:
#'   \itemize{
#'     \item A data.frame containing accident records for multiple years (must include a `year` column).
#'     \item A list of `sf` data frames, one per year.
#'   }
#' @param dist_threshold The spatial distance threshold for `calculate_local_moran`.
#' @param time_threshold The temporal distance threshold for `calculate_local_moran`.
#' @param p_value_threshold The p-value cutoff for the final consistency test.
#' @param time_column The name of the column in the accident data that contains
#'   the time information (e.g., "occurrence_hour"). Defaults to `"time"`.
#' @param year_column The name of the column indicating the year in `accident_data` (if data.frame). Defaults to `"year"`.
#'
#' @return A data frame with the final consistency test results.
#' @export
run_consistency_test <- function(network_object,
                                 accident_data,
                                 dist_threshold = 1,
                                 time_threshold = 2,
                                 p_value_threshold = 0.05,
                                 time_column = "time",
                                 year_column = "year") {

  # Input check
  if (is.data.frame(accident_data)) {
    if (!(year_column %in% names(accident_data))) {
      stop("If you pass a data.frame, it must have a 'year' column.")
    }
    # Split the data by year
    list_of_accidents <- split(accident_data, accident_data[[year_column]])
  } else if (is.list(accident_data)) {
    list_of_accidents <- accident_data
  } else {
    stop("accident_data must be either a list or a data.frame with a 'year' column.")
  }

  # Calculate Local Moran's I for each year
  list_of_moran_results <- lapply(list_of_accidents, function(accidents_data) {
    calculate_local_moran(
      set_events(network_object, accidents_data, time_column = time_column),
      dist_threshold = dist_threshold,
      time_threshold = time_threshold
    )
  })

  # Run the consistency test
  final_results <- test_spatio_properties(
    list_of_moran_results,
    p_value_threshold = p_value_threshold
  )

  return(final_results)
}

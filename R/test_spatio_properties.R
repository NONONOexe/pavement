
# ヘルパー関数
get_mode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}



# メインの検定関数
#' @export
test_spatio_properties <- function(list_of_moran_results, p_value_threshold = 0.05) {

  if (!requireNamespace("dplyr", quietly = TRUE)) stop("dplyr is required.")

  all_years_data <- dplyr::bind_rows(
    lapply(seq_along(list_of_moran_results), function(i) {
      moran_result <- list_of_moran_results[[i]]
      moran_result$moran_results |> dplyr::mutate(year = i)
    })
  )

  consistency_results <- all_years_data |>
    dplyr::group_by(segment_id, time) |>
    dplyr::summarise(
      most_likely_class = get_mode(classification),
      n_years = dplyr::n(),
      mismatch_count_k = sum(classification != most_likely_class),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      p_value = pbinom(mismatch_count_k, size = n_years, prob = 3/4),
      is_consistent = p_value <= p_value_threshold
    )

  return(consistency_results)
}


# 全ての処理をまとめた、便利なラッパー関数
#' @export
run_consistency_test <- function(segmented_network,
                                 list_of_accidents,
                                 dist_threshold = 1,
                                 time_threshold = 2,
                                 p_value_threshold = 0.05) {

  list_of_moran_results <- lapply(list_of_accidents, function(accidents_data) {
    segmented_network |>
      prepare_tnkde_data(accidents_data) |>
      calculate_local_moran(
        dist_threshold = dist_threshold,
        time_threshold = time_threshold
      )
  })

  final_results <- test_spatio_properties(
    list_of_moran_results,
    p_value_threshold = p_value_threshold
  )

  return(final_results)
}

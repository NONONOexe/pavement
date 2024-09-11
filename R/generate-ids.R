#' Generate unique IDs based on parent IDs
#'
#' This function generates unique IDs based on parent IDs.
#' It first extracts the first ID from each parent ID,
#' then ranks these IDs and uses the ranks to format the IDs.
#'
#' @param parent_list A list of parent IDs.
#' @param id_format A format string for the IDs.
#' @return A vector of unique IDs.
#' @export
#' @examples
#' parent_list <- c("rd_0001", "rd_0002", "rd_0003")
#' id_format <- "jn_%06x"
#' generate_ids(parent_list, id_format)
generate_ids <- function(parent_list, id_format) {
  # Extract the first ID from each parent ID
  first_ids <- sapply(parent_list, function(parent) parent[1])

  # Convert the hexadecimal portion of the ID to integers
  id_numbers <- strtoi(substr(first_ids, 4, nchar(first_ids)), base = 16)

  # Rank the integers
  ranked_indices <- rank(id_numbers, ties.method = "first")

  # Format the IDs based on the ranked indices
  formatted_ids <- sprintf(id_format, ranked_indices)

  return(formatted_ids)
}

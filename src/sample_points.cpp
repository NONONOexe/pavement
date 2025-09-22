#include "geometry_utils.h"

[[cpp11::register]]
cpp11::writable::list sample_points_cpp(cpp11::list sfc_linestrings,
                                        double segment_length) {
  cpp11::writable::list result_list;

  for (R_xlen_t i = 0; i < sfc_linestrings.size(); ++i) {
    cpp11::doubles_matrix<> coords_mat(sfc_linestrings[i]);

    // Convert the matrix to a vector of Point
    std::vector<Point> pts = matrix_to_points(coords_mat);

    // Sample points along the linestring
    std::vector<double> current_coords =
      sample_points_along_linestring(pts, segment_length);

    // Convert the sampled points to an R matrix
    R_xlen_t num_sampled_points = current_coords.size() / 2;
    cpp11::writable::doubles_matrix<> current_result_mat(num_sampled_points, 2);
    for (R_xlen_t j = 0; j < num_sampled_points; ++j) {
      current_result_mat(j, 0) = current_coords[2 * j];
      current_result_mat(j, 1) = current_coords[2 * j + 1];
    }

    result_list.push_back(current_result_mat);
  }

  return result_list;
}

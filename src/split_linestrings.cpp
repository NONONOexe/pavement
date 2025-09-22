#include "geometry_utils.h"

[[cpp11::register]]
cpp11::writable::list split_linestrings_cpp(cpp11::list sfc_linestrings,
                                            cpp11::list sfc_split_points,
                                            double tolerance = 0.01) {
  cpp11::writable::list result_list;

  R_xlen_t n_lines = sfc_linestrings.size();
  for (R_xlen_t i = 0; i < n_lines; ++i) {
    // Convert to points
    std::vector<Point> pts = matrix_to_points(
      cpp11::doubles_matrix<>(sfc_linestrings[i]));
    if (pts.size() < 2) {
      result_list.push_back(cpp11::writable::list());
      continue;
    }

    // Cumulative lengths
    std::vector<double> cum;
    compute_cumulative_lengths(pts, cum);

    cpp11::writable::list split_segments;

    // No split points -> original
    if (sfc_split_points.size() <= i ||
        cpp11::doubles_matrix<>(sfc_split_points[i]).nrow() == 0) {
      split_segments.push_back(points_to_matrix(pts));
      result_list.push_back(split_segments);
      continue;
    }

    // Compute cut positions
    std::vector<double> cuts =
      compute_cut_positions(cpp11::doubles_matrix<>(sfc_split_points[i]),
                            pts, cum, tolerance);
    // build segments
    std::vector<std::vector<Point>> segments =
      build_segments_from_cuts(pts, cum, cuts);

    for (const auto& seg : segments) {
      split_segments.push_back(points_to_matrix(seg));
    }

    result_list.push_back(split_segments);
  }

  return result_list;
}

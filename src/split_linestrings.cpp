#include "geometry_utils.h"

[[cpp11::register]]
cpp11::writable::list split_linestrings_cpp(cpp11::list sfc_linestrings,
                                            cpp11::list sfc_split_points,
                                            double tolerance = 0.01) {
  cpp11::writable::list result_list;

  R_xlen_t n_lines = sfc_linestrings.size();
  for (R_xlen_t i = 0; i < n_lines; ++i) {
    // read linestring coordinates
    cpp11::doubles_matrix<> coords_mat(sfc_linestrings[i]);
    R_xlen_t n_points = coords_mat.nrow();
    int dims = coords_mat.ncol();

    // if invalid, push empty list
    if (n_points < 2 || dims < 2) {
      result_list.push_back(cpp11::writable::list());
      continue;
    }

    // convert to `Point` vector
    std::vector<Point> pts;
    pts.reserve(n_points);
    for (R_xlen_t r = 0; r < n_points; ++r) {
      pts.push_back(Point{ coords_mat(r, 0), coords_mat(r, 1) });
    }

    // cumulative lengths
    std::vector<double> cum;
    compute_cumulative_lengths(pts, cum);
    double total_len = cum.back();

    // get candidate split points for this linestring
    cpp11::writable::list split_segments;

    // if no split points provided, return original linestring
    if (sfc_split_points.size() <= i ||
        cpp11::doubles_matrix<>(sfc_split_points[i]).nrow() == 0) {
      cpp11::writable::doubles_matrix<> orig_coords(n_points, 2);
      for (R_xlen_t r = 0; r < n_points; ++r) {
        orig_coords(r, 0) = coords_mat(r, 0);
        orig_coords(r, 1) = coords_mat(r, 1);
      }
      split_segments.push_back(orig_coords);
      result_list.push_back(split_segments);
      continue;
    }

    // get candidate split points for this linestring (if provided)
    std::vector<double> proj_distances;
    cpp11::doubles_matrix<> splits_mat(sfc_split_points[i]);
    R_xlen_t n_splits = splits_mat.nrow();
    for (R_xlen_t r = 0; r < n_splits; ++r) {
      Point p{ splits_mat(r, 0), splits_mat(r, 1) };
      double proj_d = 0.0;
      Point closest;
      double min_dist = 0.0;
      project_point_onto_linestring(pts, p, proj_d, closest, min_dist);
      if (min_dist <= tolerance) {
        if (proj_d < 0.0) proj_d = 0.0;
        if (total_len < proj_d) proj_d = total_len;
        proj_distances.push_back(proj_d);
      }
    }

    // unique & sorted cut distances (add start and end)
    std::sort(proj_distances.begin(), proj_distances.end());
    const double EPS_UNIQUE = 1e-9;
    std::vector<double> unique_proj;
    unique_proj.reserve(proj_distances.size());
    for (double v : proj_distances) {
      if (unique_proj.empty() ||
          EPS_UNIQUE < std::abs(unique_proj.back() - v)) {
        unique_proj.push_back(v);
      }
    }

    // assemble cuts: 0, (unique_proj excluding endpoints), total_len
    std::vector<double> cuts;
    cuts.push_back(0.0);
    for (double v : unique_proj) {
      if (1e-12 < v && v < total_len - 1e-12) {
        cuts.push_back(v);
      }
    }
    cuts.push_back(total_len);

    // create segments
    std::vector<std::vector<Point>> segments =
      build_segments_from_cuts(pts, cum, cuts);
    for (const auto& seg : segments) {
      cpp11::writable::doubles_matrix<> m(seg.size(), 2);
      for (R_xlen_t r = 0; r < static_cast<R_xlen_t>(seg.size()); ++r) {
        m(r, 0) = seg[r].x;
        m(r, 1) = seg[r].y;
      }
      split_segments.push_back(m);
    }

    result_list.push_back(split_segments);
  }

  return result_list;
}

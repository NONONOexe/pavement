#pragma once
#include <vector>
#include <cmath>
#include <limits>
#include <cpp11.hpp>

/*
 * 2D point representation with double precision.
 */
struct Point {
    double x;
    double y;
};

/*
 * Compute Euclidean distance between two points.
 */
inline double dist(const Point& a, const Point& b) {
  double dx = b.x - a.x;
  double dy = b.y - a.y;
  return std::sqrt(dx * dx + dy * dy);
}

/*
 * Compute cumulative lengths along a linestring given as a `vector<Point>`.
 *
 * `cum[i]` = distance from start to vertex `i` (`cum[0] == 0`).
 */
inline void compute_cumulative_lengths(const std::vector<Point>& pts,
                                       std::vector<double>& cum) {
  size_t n = pts.size();
  cum.assign(n, 0.0);
  for (size_t i = 1; i < n; ++i) {
    cum[i] = cum[i - 1] + dist(pts[i - 1], pts[i]);
  }
}

/*
 * Remove consecutive duplicate points (within tolerance `eps`).
 */
inline std::vector<Point> remove_consecutive_duplicates(
    const std::vector<Point>& pts,
    double eps = 1e-12) {

  std::vector<Point> result;
  result.reserve(pts.size());

  for (const auto& pt : pts) {
    if (result.empty() ||
        eps < std::abs(result.back().x - pt.x) ||
        eps < std::abs(result.back().y - pt.y)) {
      result.push_back(pt);
    }
  }

  return result;
}

/**
 * Project a point `p` onto a line segment defined by `a` and `b`
 *
 * Outputs:
 *   - out_t    : relative position along the segment [0,1]
 *   - out_proj : projected point on the segment
 *   - out_dist : Euclidean distance from `p` to projection
 */
inline void project_point_to_segment(const Point& a,
                                     const Point& b,
                                     const Point& p,
                                     double& out_t,
                                     Point& out_proj,
                                     double& out_dist) {
  double vx = b.x - a.x;
  double vy = b.y - a.y;
  double seg_len2 = vx * vx + vy * vy;

  double t;
  if (seg_len2 <= 0.0) {
    t = 0.0;
  } else {
    double wx = p.x - a.x;
    double wy = p.y - a.y;
    t = (wx * vx + wy * vy) / seg_len2;
    if (t < 0.0) t = 0.0;
    if (1.0 < t) t = 1.0;
  }

  out_proj = Point{ a.x + t * vx, a.y + t * vy };
  out_dist = dist(p, out_proj);
  out_t = t;
}

/*
 * Interpolate a coordinate along the linestring at a given distance from start.
 *
 * If `target <= 0` returns first vertex, if `total <= target` returns last
 * vertex.
 */
inline Point interpolate_point_along(const std::vector<Point>& pts,
                                     const std::vector<double>& cum,
                                     double target) {
  if (pts.empty()) return Point{ 0.0, 0.0 };

  double total = cum.back();
  if (target <= 0.0)    return pts.front();
  if (total  <= target) return pts.back();

  size_t i = 0;
  while (i + 1 < cum.size() && cum[i + 1] < target) ++i;
  double seg_len = cum[i + 1] - cum[i];
  if (seg_len <= 0.0) return pts[i];

  double t = (target - cum[i]) / seg_len;
  const Point& a = pts[i];
  const Point& b = pts[i + 1];
  return Point{ a.x + t * (b.x - a.x), a.y + t * (b.y - a.y) };
}

/*
 * Project a single point `p` onto the polyline `pts` (piecewise linear).
 *
 * Returns:
 *   - out_proj_dist: distance from start of polyline to the projected point
 *   - out_closest  : coordinates of the closest point on the polyline
 *   - out_min_dist : Euclidean distance between `p` and the closest point
 *
 * For degenerate cases (empty or 1-point input), fallback to endpoints.
 */
inline void project_point_onto_linestring(const std::vector<Point>& pts,
                                          const Point& p,
                                          double& out_proj_dist,
                                          Point& out_closest,
                                          double& out_min_dist) {
  if (pts.empty()) {
    out_closest = p;
    out_min_dist = 0.0;
    out_proj_dist = 0.0;
    return;
  }

  if (pts.size() == 1) {
    out_closest = pts[0];
    out_min_dist = 0.0;
    out_proj_dist = dist(pts[0], p);
    return;
  }

  std::vector<double> cum;
  compute_cumulative_lengths(pts, cum);
  out_min_dist = std::numeric_limits<double>::infinity();
  for (size_t i = 0; i + 1 < pts.size(); ++i) {
    double t, d;
    Point proj;
    project_point_to_segment(pts[i], pts[i + 1], p, t, proj, d);

    if (d < out_min_dist) {
      out_min_dist = d;
      out_closest = proj;
      out_proj_dist = cum[i] + t * dist(pts[i], pts[i + 1]);
    }
  }
}

/*
 * Extract sorted unique cut positions (0 and `total_len` are always included).
 * - `split_mat` : R matrix of split points
 * - `pts`       : polyline vertices
 * - `cum`       : cumulative lengths
 * - `tolerance` : maximum allowed projection distance
 */
inline std::vector<double> compute_cut_positions(
  const cpp11::doubles_matrix<>& splits_mat,
  const std::vector<Point>& pts,
  const std::vector<double>& cum,
  double tolerance) {

  double total_len = cum.back();
  std::vector<double> proj_distances;

  // Project each split point
  R_xlen_t n_splits = splits_mat.nrow();
  for (R_xlen_t r = 0; r < n_splits; ++r) {
    Point p{ splits_mat(r, 0), splits_mat(r, 1) };
    double proj_d = 0.0;
    Point closest;
    double min_dist = 0.0;
    project_point_onto_linestring(pts, p, proj_d, closest, min_dist);
    if (min_dist <= tolerance) {
      proj_d = std::clamp(proj_d, 0.0, total_len);
      proj_distances.push_back(proj_d);
    }
  }

  // Unique & sorted
  std::sort(proj_distances.begin(), proj_distances.end());
  const double EPS_UNIQUE = 1e-9;
  std::vector<double> unique_proj;
  for (double v : proj_distances) {
    if (unique_proj.empty() || EPS_UNIQUE < std::abs(unique_proj.back() - v)) {
      unique_proj.push_back(v);
    }
  }

  // Assemble final cuts
  std::vector<double> cuts;
  cuts.push_back(0.0);
  for (double v : unique_proj) {
    if (1e-12 < v && v < total_len - 1e-12) cuts.push_back(v);
  }
  cuts.push_back(total_len);

  return cuts;
}

/*
 * Convert an R matrix (`doubles_matrix<>`) to a vector of `Point`.
 * Removes consecutive duplicates in the process.
 */
inline std::vector<Point> matrix_to_points(const cpp11::doubles_matrix<>& mat) {
  std::vector<Point> pts;
  R_xlen_t n_points = mat.nrow();
  int dims = mat.ncol();
  if (n_points < 1 || dims < 2) return pts;

  pts.reserve(n_points);
  for (R_xlen_t i = 0; i < n_points; ++i) {
    pts.push_back(Point{ mat(i, 0), mat(i, 1) });
  }
  return remove_consecutive_duplicates(pts);
}

/*
 * Convert `vector<Point>` into R `double_matrix`.
 */
inline cpp11::writable::doubles_matrix<> points_to_matrix(
  const std::vector<Point>& pts) {
  cpp11::writable::doubles_matrix<> m(pts.size(), 2);
  for (R_xlen_t r = 0; r < static_cast<R_len_t>(pts.size()); ++r) {
    m(r, 0) = pts[r].x;
    m(r, 1) = pts[r].y;
  }
  return m;
}

/*
 * Sample evenly spaced points along a linestring.
 *
 * Returns a flat vector [x0, y0, x1, y1, ...].
 */
inline std::vector<double> sample_points_along_linestring(
  const std::vector<Point>& pts,
  double segment_length) {

  std::vector<double> sampled_coords;
  if (pts.size() < 2) return sampled_coords;

  std::vector<double> cum;
  compute_cumulative_lengths(pts, cum);
  double line_length = cum.back();
  int num_segments = static_cast<int>(std::round(line_length / segment_length));
  if (num_segments < 2) return sampled_coords;

  for (int i = 0; i < num_segments; ++i) {
    double target = (static_cast<double>(i) / num_segments) * line_length;
    Point p = interpolate_point_along(pts, cum, target);
    sampled_coords.push_back(p.x);
    sampled_coords.push_back(p.y);
  }
  return sampled_coords;
}

/*
 * Build segments between consecutive cut distances.
 *
 * - `cuts` must be sorted, and typically include `0` and `total_length` as
 *   first/last.
 * - returns vector of segments; each segment is `vector<Point>` with >= 2
 *   points.
 */
inline std::vector<std::vector<Point>> build_segments_from_cuts(
    const std::vector<Point>& pts,
    const std::vector<double>& cum,
    const std::vector<double>& cuts) {

  std::vector<std::vector<Point>> segments;
  const double EPS = 1e-12;

  for (size_t k = 0; k + 1 < cuts.size(); ++k) {
    double d0 = cuts[k];
    double d1 = cuts[k + 1];
    if (d1 - d0 <= EPS) continue;

    // Start point
    std::vector<Point> seg;
    Point p0 = interpolate_point_along(pts, cum, d0);
    seg.push_back(p0);

    // Include original vertices strictly between d0 and d1
    for (size_t vi = 1; vi + 1 < cum.size(); ++vi) {
      if (d0 + EPS < cum[vi] && cum[vi] < d1 + EPS) {
        seg.push_back(pts[vi]);
      }
    }

    // End point
    Point p1 = interpolate_point_along(pts, cum, d1);
    seg.push_back(p1);

    seg = remove_consecutive_duplicates(seg);

    if (2 <= seg.size()) {
      segments.push_back(std::move(seg));
    }
  }

  return segments;
}

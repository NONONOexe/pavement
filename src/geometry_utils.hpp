#pragma once
#include <vector>

struct Point {
    double x;
    double y;
};

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
 * Project a single point `p` onto the polyline `pts` (piecewise linear).
 *
 * Returns:
 *   - out_proj_dist: distance from start of polyline to the projected point
 *   - out_closest  : coordinates of the closest point on the polyline
 *   - out_min_dist : Euclidean distance between `p` and the closest point
 *
 * The function always returns values (for degenerate cases we fallback to
 * endpoints).
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
 * Interpolate a coordinate along the linestring at a given distance from
 * start.
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

    // start point
    std::vector<Point> seg;
    Point p0 = interpolate_point_along(pts, cum, d0);
    seg.push_back(p0);

    // include original vertices strictly between d0 and d1
    for (size_t vi = 1; vi + 1 < cum.size(); ++vi) {
      if (d0 + EPS < cum[vi] && cum[vi] < d1 + EPS) {
        seg.push_back(pts[vi]);
      }
    }

    // end point
    Point p1 = interpolate_point_along(pts, cum, d1);
    seg.push_back(p1);

    seg = remove_consecutive_duplicates(seg);

    if (2 <= seg.size()) {
      segments.push_back(std::move(seg));
    }
  }

  return segments;
}

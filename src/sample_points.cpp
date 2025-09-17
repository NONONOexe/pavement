#include <cpp11.hpp>
#include <vector>
#include <geos_c.h>

[[cpp11::register]]
cpp11::writable::list sample_points_cpp(cpp11::list sfc_linestrings,
                                                    double segment_length) {
  // Initialize the GEOS environment
  GEOSContextHandle_t geos_handle = GEOS_init_r();

  // Prepare a list to store the coordinate matrices of each linestring
  cpp11::writable::list result_list;

  // Iterate over each geometry in the input sfc list
  for (R_xlen_t i = 0; i < sfc_linestrings.size(); ++i) {
    // A vector to store coordinates for the current linestring
    std::vector<double> current_coords;

    // Extract the coordinate matrix for the current linestring
    cpp11::doubles_matrix<> coords_mat(sfc_linestrings[i]);
    R_xlen_t n_points = coords_mat.nrow();
    int dims = coords_mat.ncol();

    // Skip if the matrix is empty or does not have at least 2 dimensions
    if (n_points == 0 || dims < 2) {
      continue;
    }

    // Create a GEOS coordinate sequence from the matrix
    GEOSCoordSequence* seq = GEOSCoordSeq_create_r(geos_handle, n_points, dims);
    if (seq == nullptr) {
      result_list.push_back(cpp11::writable::doubles_matrix<>(0, 2));
      continue;
    }
    for (R_xlen_t j = 0; j < n_points; ++j) {
      GEOSCoordSeq_setX_r(geos_handle, seq, j, coords_mat(j, 0));
      GEOSCoordSeq_setY_r(geos_handle, seq, j, coords_mat(j, 1));
    }

    // Create a GEOS linestring from the coordinate sequence
    GEOSGeometry* geom = GEOSGeom_createLineString_r(geos_handle, seq);
    if (geom == nullptr) {
      GEOSCoordSeq_destroy_r(geos_handle, seq);
      result_list.push_back(cpp11::writable::doubles_matrix<>(0, 2));
      continue;
    }

    // Calculate the length of the current linestring
    double line_length;
    GEOSLength_r(geos_handle, geom, &line_length);

    // Calculate the number of segments to sample along the linestring
    int num_segments = static_cast<int>(round(line_length / segment_length));

    // Sample points along the linestring if there are internal points to create
    if (1 < num_segments) {
      for (int j = 1; j < num_segments; ++j) {
        double fraction = static_cast<double>(j) / num_segments;

        // Interpolate the point at the specified fraction
        GEOSGeometry* point = GEOSInterpolateNormalized_r(geos_handle, geom, fraction);

        // Extract coordinates from the interpolated point and store them
        if (point != nullptr) {
          double x, y;
          GEOSGeomGetX_r(geos_handle, point, &x);
          GEOSGeomGetY_r(geos_handle, point, &y);
          current_coords.push_back(x);
          current_coords.push_back(y);

          // Free the memory of the created point geometry
          GEOSGeom_destroy_r(geos_handle, point);
        }
      }
    }
    GEOSGeom_destroy_r(geos_handle, geom);

    // Convert the vector of coordinates for the current linestring into a matrix
    R_xlen_t num_sampled_points = current_coords.size() / 2;
    cpp11::writable::doubles_matrix<> current_result_mat(num_sampled_points, 2);
    for (R_xlen_t i = 0; i < num_sampled_points; ++i) {
      current_result_mat(i, 0) = current_coords[2 * i];     // X coordinate
      current_result_mat(i, 1) = current_coords[2 * i + 1]; // Y coordinate
    }

    // Add the matrix to our result list
    result_list.push_back(current_result_mat);
  }

  // Clean up the GEOS environment
  GEOS_finish_r(geos_handle);

  return result_list;
}

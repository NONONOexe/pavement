# Package index

## Geospatial data manipulation

Geospatial data provides insights into spatial events such as disasters
and crimes through their relationships. These functions facilitate the
retrieval and conversion data from OpenStreetMap and other external
sources, enabling you to begin your spatial analysis.

- [`fetch_roads()`](https://nononoexe.github.io/pavement/reference/fetch_roads.md)
  : Fetch road data from OpenStreetMap
- [`transform_coordinates()`](https://nononoexe.github.io/pavement/reference/transform_coordinates.md)
  [`transform_to_cartesian()`](https://nononoexe.github.io/pavement/reference/transform_coordinates.md)
  [`transform_to_geographic()`](https://nononoexe.github.io/pavement/reference/transform_coordinates.md)
  : Transform to Cartesian or geographic coordinates
- [`create_bbox()`](https://nononoexe.github.io/pavement/reference/create_bbox.md)
  : Create a bounding box
- [`convert_bbox()`](https://nononoexe.github.io/pavement/reference/convert_bbox.md)
  [`convert_bbox_to_coordinates()`](https://nononoexe.github.io/pavement/reference/convert_bbox.md)
  [`convert_bbox_to_polygon()`](https://nononoexe.github.io/pavement/reference/convert_bbox.md)
  : Convert a bounding box to coordinates or a polygon
- [`create_osm_roads()`](https://nononoexe.github.io/pavement/reference/create_osm_roads.md)
  : Create processed OpenStreetMap road data for a given area

## Network operations

### Network creation

A road network represents a system of interconnected roads, where
intersections act as nodes and road segments act as links.
`create_road_network` constructs a road network from road data. For more
detailed analysis and visualization, there is also a function,
`create_segmented_network` or `spatiotemporal_network`, to create a
segmented road network.

- [`create_road_network()`](https://nononoexe.github.io/pavement/reference/road_network.md)
  : Create a road network from roads
- [`create_segmented_network()`](https://nononoexe.github.io/pavement/reference/segmented_network.md)
  : Create a segmented road network
- [`create_spatiotemporal_network()`](https://nononoexe.github.io/pavement/reference/spatiotemporal_network.md)
  : Create spatiotemporal network
- [`plot(`*`<road_network>`*`)`](https://nononoexe.github.io/pavement/reference/plot.road_network.md)
  : Plot a road network

### Network information retrieval

These functions provide tools to extract specific information from a
road network, enabling you to understand the network structure and
relationships.

- [`get_connected_links()`](https://nononoexe.github.io/pavement/reference/get_connected_links.md)
  : Get connected links from a specified node

### Network building utilities

These functions provide tools to create and manipulate road networks.

- [`create_graph()`](https://nononoexe.github.io/pavement/reference/create_graph.md)
  : Create a graph from nodes and links
- [`extract_road_network_nodes()`](https://nononoexe.github.io/pavement/reference/extract_road_network_nodes.md)
  : Extract road network nodes
- [`extract_road_network_links()`](https://nononoexe.github.io/pavement/reference/extract_road_network_links.md)
  : Extract road network links
- [`extract_segmented_network_nodes()`](https://nononoexe.github.io/pavement/reference/extract_segmented_network_nodes.md)
  : Extract nodes of segmented network from a road network
- [`extract_segmented_network_links()`](https://nononoexe.github.io/pavement/reference/extract_segmented_network_links.md)
  : Extract segmented network links from a road network
- [`extract_road_endpoints()`](https://nononoexe.github.io/pavement/reference/extract_road_endpoints.md)
  : Extract road endpoints
- [`extract_road_intersections()`](https://nononoexe.github.io/pavement/reference/extract_road_intersections.md)
  : Extract road intersections
- [`generate_ids()`](https://nononoexe.github.io/pavement/reference/generate_ids.md)
  : Generate unique IDs based on parent IDs

## Segmented network analysis

Analyzing events on segmented road networks can provide valuable
insights into spatial relationships and patterns. By assigning events to
network links and leveraging the detailed network structure, you can
identify areas with high event frequency with these functions.

- [`create_spatiotemporal_events()`](https://nononoexe.github.io/pavement/reference/spatiotemporal_events.md)
  : Create a spatiotemporal event collection
- [`create_durations()`](https://nononoexe.github.io/pavement/reference/durations.md)
  : Create durations
- [`set_events()`](https://nononoexe.github.io/pavement/reference/set_events.md)
  : Set events on a space.
- [`find_duration()`](https://nononoexe.github.io/pavement/reference/find_duration.md)
  : Find the index of the duration that contains the event time
- [`convolute_segmented_network()`](https://nononoexe.github.io/pavement/reference/convolute_segmented_network.md)
  : Convolute segmented road network
- [`compute_epanechnikov()`](https://nononoexe.github.io/pavement/reference/compute_epanechnikov.md)
  : Compute the Epanechnikov function
- [`compute_gaussian()`](https://nononoexe.github.io/pavement/reference/compute_gaussian.md)
  : Compute the Gaussian function
- [`create_line_graph()`](https://nononoexe.github.io/pavement/reference/create_line_graph.md)
  : Create a line graph from a network

## Spatio-temporal segmented network analysis

Functions for identifying and testing spatio-temporal clusters, such as
hotspots, using methods like Local Moran’s I and TNKDE.

- [`convolute_spatiotemporal_network()`](https://nononoexe.github.io/pavement/reference/convolute_spatiotemporal_network.md)
  : Convolute a spatiotemporal network to perform TNKDE
- [`calculate_local_moran()`](https://nononoexe.github.io/pavement/reference/calculate_local_moran.md)
  : Calculate spatio-temporal local Moran's I
- [`plot(`*`<spatiotemporal_network>`*`)`](https://nononoexe.github.io/pavement/reference/plot.spatiotemporal_network.md)
  : Plot spatiotemporal network or TNKDE results
- [`plot_local_moran()`](https://nononoexe.github.io/pavement/reference/plot_local_moran.md)
  : Plot spatio-temporal local Moran's I results
- [`run_consistency_test()`](https://nononoexe.github.io/pavement/reference/run_consistency_test.md)
  : Run the full spatio-temporal consistency test
- [`test_spatio_properties()`](https://nononoexe.github.io/pavement/reference/test_spatio_properties.md)
  : Test for temporal consistency of spatio-temporal properties

## Geometry manipulation

Geometric operations are essential for spatial analysis. These functions
are helpers for working with sf functions, allowing you to create,
modify, and decompose geometries such as points, linestrings, and
polygons.

- [`create_coordinates()`](https://nononoexe.github.io/pavement/reference/create_coordinates.md)
  : Create a collection of coordinates.
- [`create_points()`](https://nononoexe.github.io/pavement/reference/create_points.md)
  : Create points geometry
- [`create_linestring()`](https://nononoexe.github.io/pavement/reference/create_linestring.md)
  : Create a linestring geometry
- [`create_polygon()`](https://nononoexe.github.io/pavement/reference/create_polygon.md)
  : Create a polygon geometry
- [`filter_and_cast_geometries()`](https://nononoexe.github.io/pavement/reference/filter_and_cast_geometries.md)
  [`get_points()`](https://nononoexe.github.io/pavement/reference/filter_and_cast_geometries.md)
  [`get_linestrings()`](https://nononoexe.github.io/pavement/reference/filter_and_cast_geometries.md)
  [`get_polygons()`](https://nononoexe.github.io/pavement/reference/filter_and_cast_geometries.md)
  : Filter and cast geometries
- [`sample_points_along_linestring()`](https://nononoexe.github.io/pavement/reference/sample_points_along_linestring.md)
  : Sample points along a linestring
- [`filter_points_within_tolerance()`](https://nononoexe.github.io/pavement/reference/filter_points_within_tolerance.md)
  : Filter points within a tolerance distance
- [`remove_points_near_endpoints()`](https://nononoexe.github.io/pavement/reference/remove_points_near_endpoints.md)
  : Remove points near endpoints of a linestring
- [`decompose_linestring()`](https://nononoexe.github.io/pavement/reference/decompose_linestring.md)
  : Decompose a linestring into a list of line segments
- [`split_linestrings()`](https://nononoexe.github.io/pavement/reference/split_linestrings.md)
  : Split multiple linestrings into segments

## Sample data

Pre-generated sample datasets related to roads and accidents. These
datasets can be used to immediately begin using pavement.

- [`sample_roads`](https://nononoexe.github.io/pavement/reference/sample_roads.md)
  : Sample roads data
- [`sample_accidents`](https://nononoexe.github.io/pavement/reference/sample_accidents.md)
  : Sample accidents data
- [`sample_accidents_multiyear`](https://nononoexe.github.io/pavement/reference/sample_accidents_multiyear.md)
  : Sample accident data for five years
- [`osm_highway_values`](https://nononoexe.github.io/pavement/reference/osm_highway_values.md)
  : Values for the 'highway' tag in OpenStreetMap data
- [`jdg2011_datum`](https://nononoexe.github.io/pavement/reference/jdg2011_datum.md)
  : Japan Geodetic Datum 2011 (JDG2011) Reference Points

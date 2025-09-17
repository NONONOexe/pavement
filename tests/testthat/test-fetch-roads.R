test_that(
  "`fetch_roads()` works with valid bounding box and `crop = TRUE`",
  {
    local_mocked_bindings(osmdata_sf = function(q) mock_osmdata_sf,
                          .package = "osmdata")

    bbox <- create_bbox(
      north =  35.17377,
      south =  35.16377,
      east  = 136.91590,
      west  = 136.90090
    )

    roads <- fetch_roads(bbox, crop = TRUE)

    expect_s3_class(roads, "sf")
    expect_true(all(
      c("id", "highway", "name", "layer", "oneway", "osm_id") %in% names(roads)
    ))
    expect_true(all(sf::st_geometry_type(roads) == "LINESTRING"))

    # Check the bounding box (cropped)
    expect_true(all(c(
      bbox[, "min"] - 0.00001 <= sf::st_bbox(roads)[c("xmin", "ymin")],
      sf::st_bbox(roads)[c("xmax", "ymax")] <= bbox[, "max"] + 0.00001
    )))
  }
)

test_that(
  "`fetch_roads()` works with valid bounding box and `crop = FALSE`",
  {
    local_mocked_bindings(osmdata_sf = function(q) mock_osmdata_sf,
                          .package = "osmdata")

    bbox <- create_bbox(
      north =  35.17377,
      south =  35.16377,
      east  = 136.91590,
      west  = 136.90090
    )

    roads <- fetch_roads(bbox, crop = FALSE)

    expect_s3_class(roads, "sf")
    expect_true(all(
      c("id", "highway", "name", "layer", "oneway", "osm_id") %in% names(roads)
    ))
    expect_true(all(sf::st_geometry_type(roads) == "LINESTRING"))

    # Check the bounding box (NOT cropped)
    expect_false(all(c(
      bbox[, "min"] - 0.00001 <= sf::st_bbox(roads)[c("xmin", "ymin")],
      sf::st_bbox(roads)[c("xmax", "ymax")] <= bbox[, "max"] + 0.00001
    )))
  }
)

test_that("`extract_road_intersections` works with valid input", {
  intersections <- extract_road_intersections(sample_roads)

  expect_s3_class(intersections, "sf")
  expect_named(intersections, c("parent_road", "num_overlaps", "geometry"))
  expect_equal(nrow(intersections), 3)

  expect_equal(intersections$parent_road[[1]], c("rd_0003", "rd_0004"))
  expect_equal(intersections$parent_road[[2]], c("rd_0002", "rd_0006"))
  expect_equal(intersections$parent_road[[3]], c("rd_0005", "rd_0006"))

  expect_equal(intersections$num_overlaps[[1]], 2)
  expect_equal(intersections$num_overlaps[[2]], 2)
  expect_equal(intersections$num_overlaps[[3]], 2)
})

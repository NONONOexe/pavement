

bounding_box <- create_bbox(
  # 分析対象地域の経度，緯度
  # west, east, south, north = 136.8736, 136.9449, 35.1478, 35.1886
  north = 35.1886,
  south = 35.1478,
  east = 136.9449,
  west = 136.8736
)

# 道路データを取得
roads <- pavement::fetch_roads(
  bounding_box,
  overpass_url = "https://overpass-api.de/api/interpreter",
  crop = TRUE,
) |> transform_to_cartesian()

saveRDS(roads, file = "data/processed_roads.Rds")


# 事故データの取得とフィルタリング
accident_data <- accidents_analysis
filter_area <- bounding_box |>
  convert_bbox_to_polygon(crs = st_crs(accident_data))
filtered_data <- accident_data |>
  st_filter(filter_area) |>
  transform_to_cartesian()

# 道路ネットワークに変換
road_network <- create_road_network(roads) |>
  set_events(filtered_data)


segmented_network <- road_network |>
  create_segmented_network(segment_length = 50) |>
  convolute_segmented_network(bandwidth = 250)

saveRDS(segmented_network, "data/network_kde.Rds")



# ------- tnkde ---------
filtered_data <- filtered_data |>
  dplyr::rename(time = occurrence_hour)


tnkde_network <- roads |>
  create_road_network() |>
  create_segmented_network(segment_length = 50) |>
  prepare_tnkde_data(filtered_data) |>
  convolute_spatiotemporal_network(
    bandwidth_space = 250,
    bandwidth_time = 2.5,
    time_points = 0:23
  )

saveRDS(tnkde_network, "data/tnkde.Rds")

# # sf オブジェクトとして必要な列だけ選択
# segments_sf   <- convolute_segmented_network$segments |> select(id, geometry)
# nodes_sf   <- convolute_segmented_network$nodes |> select(id, geometry)
# events_sf  <- convolute_segmented_network$events |> select(id = accident_id, geometry)
#
# # 中心座標
# center_lon <- mean(bounding_box["x", ])
# center_lat <- mean(bounding_box["y", ])
#
# # 描画
# maplibre(
#   style = carto_style("positron-no-labels"),
#   center = c(center_lon, center_lat),
#   zoom = 14
# ) |>
#   # 道路セグメント
#   add_source(id = "network_edges", data = segments_sf) |>
#   add_line_layer(
#     id = "network_layer",
#     source = "network_edges",
#     line_color = "blue",
#     line_width = 2
#   ) |>
#   # 交差点ノード
#   add_source(id = "network_nodes", data = nodes_sf) |>
#   add_circle_layer(
#     id = "node_layer",
#     source = "network_nodes",
#     circle_color = "red",
#     circle_radius = 4
#   ) |>
#   # 事故イベント
#   add_source(id = "network_events", data = events_sf) |>
#   add_circle_layer(
#     id = "event_layer",
#     source = "network_events",
#     circle_color = "yellow",
#     circle_radius = 6
#   )
#
#
#
#
# # --------------------- 面積1/4のテスト用 ---------------------
#
# small_bbox <- create_bbox(
#   west  = x_center - new_width/2,
#   east  = x_center + new_width/2,
#   south = y_center - new_height/2,
#   north = y_center + new_height/2
# )
#
# small_roads <- pavement::fetch_roads(
#   small_bbox,
#   overpass_url = "https://overpass-api.de/api/interpreter",
#   crop = TRUE,
# ) |> transform_to_cartesian()
#
# # 事故データの取得とフィルタリング
# accident_data <- traffic_accidents_2020
# small_filter_area <- small_bbox |>
#   convert_bbox_to_polygon(crs = st_crs(accident_data))
# small_filtered_data <- accident_data |>
#   st_filter(small_filter_area) |>
#   transform_to_cartesian()
#
# # 道路ネットワークに変換
# small_road_network <- create_road_network(small_roads) |>
#   set_events(small_filtered_data)
#
# small_segmented_network <- small_road_network |>
#   create_segmented_network(segment_length = 50)
#
#
# small_convolute_segmented_network <- small_segmented_network |>
#   convolute_segmented_network(bandwidth = 250)
#
#
# # sf オブジェクトとして必要な列だけ選択
# small_segments_sf   <- small_convolute_segmented_network$segments |> select(id, geometry)
# small_nodes_sf   <- small_convolute_segmented_network$nodes |> select(id, geometry)
# small_events_sf  <- small_convolute_segmented_network$events |> select(id = accident_id, geometry)
#
# # 中心座標
# small_center_lon <- mean(small_bbox["x", ])
# small_center_lat <- mean(small_bbox["y", ])
#
# # 描画
# maplibre(
#   style = carto_style("positron-no-labels"),
#   center = c(small_center_lon, small_center_lat),
#   zoom = 14
# ) |>
#   # 道路セグメント
#   add_source(id = "network_edges", data = small_segments_sf) |>
#   add_line_layer(
#     id = "network_layer",
#     source = "network_edges",
#     line_color = "blue",
#     line_width = 2
#   ) |>
#   # 交差点ノード
#   add_source(id = "network_nodes", data = small_nodes_sf) |>
#   add_circle_layer(
#     id = "node_layer",
#     source = "network_nodes",
#     circle_color = "red",
#     circle_radius = 4
#   ) |>
#   # 事故イベント
#   add_source(id = "network_events", data = small_events_sf) |>
#   add_circle_layer(
#     id = "event_layer",
#     source = "network_events",
#     circle_color = "orange",
#     circle_radius = 6
#   )

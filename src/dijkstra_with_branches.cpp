#include <cpp11.hpp>
#include <vector>
#include <queue>
using namespace cpp11;

// Define a state for the priority queue
using state = std::pair<double, int>;

[[cpp11::register]]
cpp11::writable::list dijkstra_with_branches(const cpp11::list& adj,
                                             const cpp11::list& edge_weights,
                                             const cpp11::list& branch_degrees,
                                             int start_node_r,
                                             int n_nodes) {
  // Convert to 0-based index
  int start_node = start_node_r - 1;

  // Prepare output vectors
  std::vector<double> dist(n_nodes, std::numeric_limits<double>::infinity());
  std::vector<double> branch_factors(n_nodes, 1.0);

  dist[start_node] = 0.0;

  // Prepare priority queue
  std::priority_queue<state, std::vector<state>, std::greater<state>> pq;
  pq.push({0.0, start_node});

  while (!pq.empty()) {
    double d = pq.top().first;
    int u = pq.top().second;
    pq.pop();

    // Skip if we found a better path
    if (dist[u] < d) continue;

    cpp11::integers neighbours = adj[u];
    cpp11::doubles  weights_u  = edge_weights[u];
    cpp11::integers degrees_u  = branch_degrees[u];

    for (int i = 0; i < neighbours.size(); ++i) {
      int    v         = neighbours[i] - 1; // Convert to 0-based index
      double weight_uv = weights_u[i];
      int    degree_uv = degrees_u[i];

      // Update distance and branch factor if a better path is found
      if (dist[u] + weight_uv < dist[v]) {
        dist[v]           = dist[u] + weight_uv;
        branch_factors[v] = branch_factors[u] * std::max(1, degree_uv - 1);
        pq.push({dist[v], v});
      }
    }
  }

  // Convert results to R types
  cpp11::writable::doubles dist_out(dist.begin(), dist.end());
  cpp11::writable::doubles branches_out(branch_factors.begin(),
                                        branch_factors.end());

  return cpp11::writable::list({
    "distances"_nm = dist_out,
    "branches"_nm  = branches_out
  });
}

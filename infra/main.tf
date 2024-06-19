resource "google_container_cluster" "primary" {
  name     = "primary-cluster"
  location = "asia-southeast2"
  
  node_config {
    machine_type = "e2-medium"
  }
  
  initial_node_count = 3
}

resource "google_container_node_pool" "primary_nodes" {
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location
  node_count = 3

  node_config {
    machine_type = "e2-medium"
  }
}
#Bucket to store website
resource "google_storage_bucket" "website" {
    name     = "example-website-by-alif"
    location = "US"
}

#make new object public
resource "google_storage_object_access_control" "public_rule" {
    object = google_storage_bucket_object.website.name
    bucket = google_storage_bucket.website.name
    role   = "READER"
    entity = "allUsers"
}

#upload html file to the bucket
resource "google_storage_bucket_object" "website" {
    name   = "index.html"
    bucket = google_storage_bucket.website.name
    source = "../website/index.html"
}

#reserve a static externalal IP  (LOAD BALANCER)
resource "google_compute_global_address" "website_ip" {
    name = "website-lb-ip"
}

#get the amanaged DNS Zone
data "google_dns_managed_zone" "dns_zone" { 
    name = "terraform-gcp"
}

#Add IP Address to the DNS Zone
resource "google_dns_record_set" "website" {
    managed_zone = data.google_dns_managed_zone.dns_zone.name
    name         = "website.${data.google_dns_managed_zone.dns_zone.dns_name}"
    type         = "A"
    ttl          = 300
    rrdatas      = [google_compute_global_address.website_ip.address]
}

#Add the bucket as a CDN bucket
resource "google_compute_backend_bucket" "website-backend" {
    name    = "website-bucket"
    bucket_name = google_storage_bucket.website.name
    description = "Contains files needed for the bucket"
    enable_cdn = true
}

#GCP URL MAP
resource "google_compute_url_map" "website" {
    name            = "website-url-map"
    default_service = google_compute_backend_bucket.website-backend.self_link
    host_rule {
        hosts = ["*"]
        path_matcher = "allpaths"
    }
    path_matcher {
        name = "allpaths"
        default_service = google_compute_backend_bucket.website-backend.self_link
    }
}

# GCp HTTP Proxy
resource "google_compute_target_http_proxy" "website" {
    name    = "website-target-proxy"
    url_map = google_compute_url_map.website.self_link
}

#GCP forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
    name       = "website-forwarding-rule"
    load_balancing_scheme = "EXTERNAL"
    target     = google_compute_target_http_proxy.website.self_link
    port_range = "80"
    ip_address = google_compute_global_address.website_ip.address
    ip_protocol = "TCP"
}